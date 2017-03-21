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
    export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
    export PATH=$HOME/.local/bin:$PATH
    cd $HOME
    if test -x $HOME/.local/bin/bash; then
        export PS1='\[\e]0;\h:\w\a\]\n\[\e[01;32m\]\u@\h\[\e[00;33m\] \w\n\[\e[1;$((31+3*!$?))m\]\$\[\e[00m\] '
        exec $HOME/.local/bin/bash --login
    else
        export PS1='\[\e[01;32m\]\u@\h\[\e[00;33m\] \w \[\e[1;$((31+3*!$?))m\]\$\[\e[00m\] '
        exec $HOME/.local/bin/sh --login
    fi
else
    export HOME=/tmp/root
    mkdir -p $HOME/.local/bin
    cd $HOME/.local/bin
    wget http://phuslu.github.io/mips/busybox-mipsel -O busybox
    wget http://phuslu.github.io/mips/bash-mipsel -O bash
    wget http://files.lancethepants.com/Binaries/htop/mipsel/htop%201.0.3/htop
    wget http://files.lancethepants.com/Binaries/curl/mipsel/curl%207.40.0%20%28MIPSR1%29/curl
    chmod +x busybox bash htop curl
    $HOME/.local/bin/busybox --install -s .
    wget http://phuslu.github.io/bashrc -O $HOME/.bash_login
fi

