export PATH=/usr/local/bin:~/Applications/bin:$PATH
export CVS_RSH=ssh
export EDITOR=emacs
export SVN_LOG_EDITOR=emacs

source ~/Documents/Source/Git/git/contrib/completion/git-completion.bash

PS1='\u@\h:\w\$ '
SHORT_HOSTNAME=$(hostname -s)
PROMPT_COMMAND='echo -ne "\033]0;${USER}@${SHORT_HOSTNAME}:${PWD/$HOME/~}\007"'

export HISTCONTROL=erasedups
export HISTSIZE=100000
shopt -s histappend
shopt -s histverify

# Disable flow control.
stty -ixon
