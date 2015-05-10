#include <unistd.h>
#include <stdio.h>

int main(void){
  int i;
  for (i = 20; i >= 0; i--)
  {
    //printf("%d\n",i);
    sleep(1);
  }
  return 0;
}
