#!/usr/bin/python

def displaySurvey ( ):
        f = open('survey.ssv')
        tmp = f.readline()
        if tmp != 'END_SURVEY':
                print "Survey title: ", tmp, "<br>"
                count = 1
                for line in f:
                        newline = "Question " + str(count) + ": " + line + "<br>"
                        print newline
                        count += 1
        f.close ( )
        print "<hr>"
        return

# displaySurvey ()