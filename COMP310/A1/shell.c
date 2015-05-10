#include <sys/wait.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>

#define MAX_LINE 80 /* 80 chars per line, per command, should be enough. */
#define MAX_HIST_CMDS 10 /* Keep the 10 most recent commands */
#define MAX_CONCURRENT_PROCS 40 /* Permit only 40 concurrent processes */

/**
 * setup() reads in the next command line, separating it into distinct tokens
 * using whitespace as delimiters. setup() sets the args parameter as a
 * null-terminated string.
 */
int setup(char inputBuffer[], char *args[],int *background)
{
  int length, /* # of characters in the command line */
      i,      /* loop index for accessing inputBuffer array */
      start,  /* index where beginning of next command parameter is */
      ct;     /* index of where to place the next parameter into args[] */

  ct = 0;
  /* read what the user enters on the command line */
  length = read(STDIN_FILENO, inputBuffer, MAX_LINE);
  start = -1;
  /* I made a modification because the following section has a problem where
   * if the ^d is on a line with input it will cause memory access errors */
  if (length == 0)
    exit(EXIT_SUCCESS);  /* ^d was entered, end of user command stream */
  else if (length < 0)
  {
    perror("Error: Could not read the command");
    exit(EXIT_FAILURE);  /* terminate with error code of -1 */
  }
  /* examine every character in the inputBuffer */
  for (i=0;i<length;i++)
  {
    switch (inputBuffer[i])
    {
      case ' ':
      case '\t' :                /* argument separators */
        if(start != -1)
        {
          args[ct] = &inputBuffer[start]; /* set up pointer */
          ct++;
        }
        inputBuffer[i] = '\0';   /* add a null char; make a C string */
        start = -1;
      break;
      case '\n':                 /* should be the final char examined */
        if (start != -1)
        {
          args[ct] = &inputBuffer[start];
          ct++;
        }
        inputBuffer[i] = '\0';
        args[ct] = NULL;         /* no more arguments to this command */
      break;
      default :                  /* some other character */
        if (inputBuffer[i] == '&')
        {
          *background = 1;
          inputBuffer[i] = '\0';
        }
        else if (start == -1)
          start = i;
    }
  }
  args[ct] = NULL;   /* just in case the input line was > 80 */
  /* This next part checks if we were able to parse some input */
  if (ct==0)
    return -1;
  else if (args[0]==NULL) 
    return -1;
  else
    return 0;
}

/** addCmdToHistory() accepts an array of array of strings as the history
 *  and an array of strings that represents the newest command to add. 
 *  It begins by moving all the strings up one array cell (what was in 8 is 
 *  moved to 9 and so forth). Then it copies the newest command into cell 0.
 *  The lower the index, the more recent the command. */
void addCmdToHistory(char history[][MAX_LINE/+2][MAX_LINE], char *args[])
{
  int i, j;

  for (i = (MAX_HIST_CMDS-1); i>0; i--)
  {
    for (j = 0; j<(MAX_LINE/+2); j++)
      strcpy(history[i][j], history[i-1][j]);
  }
  for (i=0; args[i]!=NULL; i++)
    strcpy(history[0][i], args[i]);
  for ( ; i<(MAX_LINE/+2); i++)
    history[0][i][0]='\0';
}

/** 
 * getCmdFromHistory() accepts the array of history strings and the array of 
 * strings that contains the arguments array that will be used for the 
 * execution invocation. */
void getCmdFromHistory(char history[][MAX_LINE/+2][MAX_LINE], char *args[])
{
  char cmdBeginsWith;
  char newArgs[MAX_LINE/+2][MAX_LINE];
  int i, j;

  if (args[1]!=NULL)
    cmdBeginsWith = *args[1];
  for (i = 0; i < MAX_HIST_CMDS; i++)
  {
    if (history[i][0][0] == cmdBeginsWith)
    {
      for (j = 0; j<  (MAX_LINE/+2); j++)
        args[j] = malloc(MAX_LINE * sizeof(char));
      for (j = 0; history[i][j][0] != '\0'; j++)
        strcpy(args[j], history[i][j]);
      for ( ; j < (MAX_LINE/+2); j++)
      {
        args[j]=NULL;
        free(args[j]);
      }
      return;
    }
  }
}

/** 
 * invokeCommand() accepts the arguments and the background bit
 * int and excutes the given command. Then it returns the PID of the child
 * process. */
int invokeCommand(char *args[], int background)
{
  int i, cpid;

  cpid = fork();
  if (cpid == 0)
  {
    execvp(args[0],args);
    exit(EXIT_SUCCESS);
  }
  else if (cpid > 0)
  {
    if (background == 0)
      waitpid(cpid, NULL, 0);
  }
  else if (cpid < 0)
  {
    perror("Error: Could not create a child process\n");
    exit(EXIT_FAILURE);
  }
  return cpid;
}

/** 
 * addProcToJobs() accepts the pid and an array representing the jobs and adds
 * the given pid to the array if the maximum number of concurrent processes has
 * not been exceeded. */
void addProcToJobs(int pid, int jobs[MAX_CONCURRENT_PROCS])
{
  int i;

  for (i = 0; (i < MAX_CONCURRENT_PROCS && jobs[i] != -1) ; i++) { }
  if (i >= MAX_CONCURRENT_PROCS)
  {
    perror("Error: Maximum concurrent processes exceeded");
    exit(EXIT_FAILURE);
  }
  else
    jobs[i] = pid;
}

/** 
 * cleanUpJobs() accepts the jobs array then iterates through it and removes the
 * processes that have terminated */
void cleanUpJobs(int jobs[MAX_CONCURRENT_PROCS])
{
  int i, j, lf;

  for (i = 0; i < MAX_CONCURRENT_PROCS ; i++)
  {
    if (jobs[i] != -1)
    {
      if (waitpid(jobs[i], NULL, WNOHANG) != 0)
        jobs[i] = -1;
    }
  }
  for (lf = MAX_CONCURRENT_PROCS - 1; (jobs[lf] == -1 && lf >= 0); lf--) { }
  for (i = 0; i < lf; i++)
  {
    if (jobs[i] == -1)
    {
      for (j = lf; (j >= 0 && jobs[j] == -1); j--) { }
      jobs[i] = jobs[j];
      jobs[j] = -1;
    }
  }
}

int main(void)
{
  char inputBuffer[MAX_LINE]; /* buffer to hold the command entered */
  int background;             /* equals 1 if a command is followed by '&' */
  char *args[MAX_LINE/+2];    /* command line (of 80) has max of 40 args */
  char history[MAX_HIST_CMDS][MAX_LINE/+2][MAX_LINE];
  int jobs[MAX_CONCURRENT_PROCS];
  int i;

  /* Initialize the jobs array */
  for (i = 0; i < MAX_CONCURRENT_PROCS; i++)
  {
    jobs[i] = -1;
  }

  while (1) /* Program terminates normally inside setup */
  {
    cleanUpJobs(jobs);
    background = 0;
    printf(" COMMAND->\n");

    if (setup(inputBuffer,args,&background) != 0) /* get next command */
      continue;
    else if (inputBuffer[0] == '\0')      /* check if inputBuffer is empty */
      continue;
    else if (strcmp(args[0],"r") == 0)    /* history mode */
    {
      getCmdFromHistory(history, args);

      /* check whether a match was found */
      if (strcmp(args[0],"r") == 0)
      {
        printf("Warning: No matching command found\n");
        continue;
      }

      /* echo the command from history */
      printf(" COMMAND->\n");
      for (i = 0; (i < (MAX_LINE/+2) && args[i] != '\0'); i++)
        printf("%s ",args[i]);
      printf("\n");

      addCmdToHistory(history, args);
      addProcToJobs(invokeCommand(args, background), jobs); 
    }
    else if (strcmp(args[0],"cd") == 0)   /* built in command : cd */
    {
      if (args[1] != NULL)
      {
        if (chdir(args[1]) != 0)
          printf("Warning: No such file or directory\n");
      }
    }
    else if (strcmp(args[0],"pwd") == 0)  /* built in command : pwd */
      printf("%s\n",getcwd(NULL, MAX_LINE));
    else if (strcmp(args[0],"jobs") == 0) /* built in command : jobs */
    {
      cleanUpJobs(jobs);
      printf("\nPIDs\n");
      for (i = 0; (i < MAX_CONCURRENT_PROCS && jobs[i] != -1) ; i++)
        printf("%d\n",jobs[i]);
    }
    else if (strcmp(args[0],"fg") == 0)   /* built in command : fg */
    {
      if (args[1] != NULL)
        waitpid(atoi(args[1]), NULL, 0);
    }
    else
    {
      addCmdToHistory(history, args);
      addProcToJobs(invokeCommand(args, background), jobs);
    }
  }
}
