#!/bin/sh
# visit http://192.168.1.1/setup.cgi?todo=debug to enable telent
if test -x /tmp/root/.local/bin/busybox; then
        export TERM=xterm
        export USER=root
        export HOME=/tmp/root
        export HISTTIMEFORMAT="%Y-%m-%d %T "
        export HISTCONTROL=ignoreboth
        export HISTSIZE=100000
        export HISTFILESIZE=2000000
        export TERM=xterm
        export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
        export PATH=/tmp/root/.local/bin:$PATH
        cd $HOME
        if test -x /tmp/root/.local/bin/bash; then
                export PS1='\[\e]0;\h:\w\a\]\n\[\e[01;32m\]\u@\h\[\e[00;33m\] \w\n\[\e[1;$((31+3*!$?))m\]\$\[\e[00m\] '
                exec /tmp/root/.local/bin/bash --login
        else
                export PS1='\[\e[01;32m\]\u@\h\[\e[00;33m\] \w \[\e[1;$((31+3*!$?))m\]\$\[\e[00m\] '
                exec /tmp/root/.local/bin/sh --login
        fi
else
        mkdir -p /tmp/root/.local/bin
        cd /tmp/root/.local/bin
        wget http://phuslu.github.io/mips/busybox-mipsel -O busybox
        wget http://phuslu.github.io/mips/bash-mipsel -O bash
        wget http://files.lancethepants.com/Binaries/htop/mipsel/htop%201.0.3/htop
        wget http://files.lancethepants.com/Binaries/curl/mipsel/curl%207.40.0%20%28MIPSR1%29/curl
        chmod +x busybox bash htop curl
        /tmp/root/.local/bin/busybox --install -s .
        wget http://phuslu.github.io/bashrc -O /tmp/root/.bash_login
fi

