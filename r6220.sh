# inspired from http://www.right.com.cn/forum/thread-208580-1-1.html
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
        mkdir /tmp/root/.local/bin
        wget http://phuslu.github.io/mips/busybox-mipsel -O /tmp/root/.local/bin/busybox
        chmod +x /tmp/root/.local/bin/busybox
        /tmp/root/.local/bin/busybox --install -s /tmp/root/.local/bin
        wget http://phuslu.github.io/mips/bash-mipsel -O /tmp/root/.local/bin/bash
        chmod +x /tmp/root/.local/bin/bash
        wget http://phuslu.github.io/mips/.bashrc -O /tmp/root/.bashrc
fi

