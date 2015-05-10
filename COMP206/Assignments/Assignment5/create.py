#!/usr/bin/python

import re
import os
import sys
import urllib
import cgi
from newSurvey import newSurvey
from addQuestion import addQuestion
from endSurvey import endSurvey
from displaySurvey import displaySurvey

def cgi2html(string):
        string = re.sub("%(.)(.)", lambda s: '&#' + str(int(s.group()[1:], 16)) + ';', string, re.DOTALL)
        return re.sub("\+", " ", string)

# NOTE: The SOCS server uses Python 2.5.2
# which doesn't have urlparse.parse_qs()

def parse_qs(str):
        map = {}
        b = str.split("&")
        if b == None:
                b = [a[1]]
        for pair in b:
                assoc = pair.split("=")
                if len(assoc) == 2:
                        map[assoc[0]] = cgi2html(assoc[1])
        return map

def read_POST():
        qs = ""
        for line in sys.stdin:
                qs += line
        return qs

def printfromfile(str):
        f = open(str)
        for line in f:
                print line,
        f.close()
        return

print "Content-Type: text/html"
print ""
print "<html>"

printfromfile('create_header.html')

post_qs = read_POST()
inputs = parse_qs(post_qs)

if post_qs != "":
        if inputs['selection'] == 'NEW':
                if inputs['title'] != "":
                        newSurvey( inputs['title'] )
                else:
                        print "Title was empty, please try again <br><br>"
                displaySurvey ( )
                printfromfile('create_form.html')

        elif inputs['selection'] == 'ADD':
                if inputs['question'] != "":
                        addQuestion( inputs['question'] )
                else:
                        print "Question field was empty, please try again <br><br>"
                displaySurvey ( )
                printfromfile('create_form.html')

        elif inputs['selection'] == 'DONE':
                displaySurvey( )
                endSurvey ( )
        else:
                print "Improper selection, please press a button! <br>"
else:
        print "Loading survey on file: <br><br>"
        displaySurvey ( )
        printfromfile('create_form.html')

printfromfile('create_footer.html')