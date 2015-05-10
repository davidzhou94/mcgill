#!/usr/bin/python

def addQuestion ( str ):
        f = open('survey.ssv','a')
        newline = str + '\n'
        f.write( newline )
        return
