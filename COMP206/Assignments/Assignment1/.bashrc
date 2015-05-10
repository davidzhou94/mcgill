# .bashrc

# Source global definitions
if [ -f /usr/socs/Profile ]; then
        . /usr/socs/Profile
fi

# User specific aliases and functions

echo 'Hello David'
alias wow='echo such doge'

alias lsa='ls -l -A'
alias sbackup='bash ~/Source/backup'
SOTEMP=$PS1
PS1=$SOTEMP'[wow such motto] '

