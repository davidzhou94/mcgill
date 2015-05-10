#!/usr/bin/python

def newSurvey( title ):
        f = open('survey.ssv', 'w')
        newline = title + '\n'
        f.write(newline)
        f.close()

        return