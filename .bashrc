#
# /etc/bash.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

[[ $DISPLAY ]] && shopt -s checkwinsize

alias grep='grep --color=auto'
alias ls='exa --group-directories-first'
alias ll='exa -l --group-directories-first'
alias sume='sudo -E'
alias fucking='sudo'
alias 'cd..'='cd ..'
alias bk='cd -'
alias gitwhat='git log -p -M --follow --stat --'


if [[ $EUID -eq 0 ]]; then
    export PATH="$PATH:~/.local/bin:~/.cargo/bin"
else
    #if youre not root as a fall back check current dir for command
    export PATH="$PATH:~/.local/bin:~/.cargo/bin:."
fi
export EDITOR='nvim'

[ -r /usr/share/bash-completion/bash_completion   ] && . /usr/share/bash-completion/bash_completion
#ps1_proc_result () {
#    [[ $1 -ne 0 ]] && printf "\033[43;33m \033[43;31m$1"
#}

# restriction being needs git 1.6.3 or newer
__git_ps1 () {
    git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '-'
}

#PROMPT_COMMAND='ps1_ret=$?'
PS1="\[\e[34m\]\D{%T}\[\e[35m\](\`__git_ps1\`)\[\e[36m\]\u\[\e[m\]@\[\e[32m\]\h\[\e[m\]:\[\e[33m\]\W\[\e[m\]\$ "

export LC_CTYPE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
#this is to get around the fact that no one knows what termite is so ssh'ing is a pain
[[ $TERM != 'screen-256color' ]] && export TERM=xterm-256color

[ -f /usr/bin/clang ] && export CC=/usr/bin/clang
[ -f /usr/bin/clang++ ] && export CXX=/usr/bin/clang++

#fuck that stupid Ctl-s bullshit
stty -ixon

#if we ran wall lets get dem colors
#(wal -r -t &)
#wal is too much im disabling it

#change laptop brightness
function bri () {
    echo $1 > /sys/class/backlight/amdgpu_bl0/brightness
}

#cp image to clipboard
function cpi () {
    xclip -selection clipboard -t image/png -i $1
}

#get the last scratch file or nth to the end from the vim scratch system
function lastscratch () {
    if [[ "$1" == "" ]]; then
        lastscratch=`find $HOME/.vimscratch/ -type f | sort | tail -n 1`
    else
        lastscratch=`find $HOME/.vimscratch/ -type f | sort | tail -n $1 | head -n 1`
    fi
    cat $lastscratch
}

#is it raining
function rain () {
    curl -s https://isitraining.in/vancouver | grep -oP '(?<=>)Yes|No(?=<)'
}

#slack formatting is dumb, this makes it less dumb
function slackfmt () {
    sed -E 's/^/    /' | sed -E 's/^([ ]{4,})(.+)([0-9]{2}:[0-9]{2})/\2/' | sed -E 's/[ ]{4,}[0-9]{2}:[0-9]{2}//' | sed -E 's/^[ ]{5,}/    /' | grep .
}

#new changes reload
function reloadterm () {
    killall -USR1 termite
}

#what the weather currently is
function weather () {
    curl wttr.in
}

#find leetspeekable names from text data
function leetify () {
    grep -oP '^([0-9a-fots]|(?<!i)l|(?<!l)i){4,7}$' | sort -R | head -n 25 | tee ~/tmp | tr 'aeolits' '4301175' | tr a-z A-Z > ~/tmp2 && paste -d"\t" ~/tmp ~/tmp2 && rm ~/tmp ~/tmp2
}

#change filenames to be only sane characters
function mvsane () {
    for F in "$@"
    do
        mv "$F" $(echo "$F" | sed -r 's/[ ]+/_/g' | sed -r 's/[^a-zA-Z0-9_.-]//g' | sed -r 's/[_-]{2,}/-/g')
    done
}

#thanks to john saying this:
#   [15:51] john_a_macdonald: Oh fuck off
#       The only worse option is mixing the digits
#       I prefer listing dates as YDYY-MD-MY
#i made it a thing
function bestdate () {
    date '+%Y-%m-%d' | sed -r 's/([0-9])([0-9])([0-9])([0-9])-([0-9])([0-9])-([0-9])([0-9])/\1\7\3\4-\5\8-\6\2/'
}

#test truecolor support (youll know if it doesnt work)
function truecolortest () {
    awk 'BEGIN{
    s="/\\/\\/\\/\\/\\"; s=s s s s s s s s;
    for (colnum = 0; colnum<77; colnum++) {
        r = 255-(colnum*255/76);
        g = (colnum*510/76);
        b = (colnum*255/76);
        if (g>255) g = 510-g;
            printf "\033[48;2;%d;%d;%dm", r,g,b;
            printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
            printf "%s\033[0m", substr(s,colnum+1,1);
        }
        printf "\n";
    }'
}

#thanks to this https://gist.github.com/timperez/7892680 im adding whoisport
function whoisport () {
        port=$1
        pidInfo=$(fuser $port/tcp 2> /dev/null)
        pid=$(echo $pidInfo | cut -d':' -f2)
        ls -l /proc/$pid/exe
}

#useful for debugging with binding with strace or whatever to a running process
#starts a process stopped
function startstopped () {
    ( kill -SIGSTOP $BASHPID; exec $@ ) &
}
#lets it continue
function resumestopped () {
    kill -SIGCONT $(jobs -l | grep '( kill -SIGSTOP $BASHPID; exec $@ )' | awk '{print $2}')
}

#convert files to shellcode escaped strings
function shellencode () {
    for F in "$@"
    do
        printf '"' && xxd -g 0 $F | awk '{print $2}' | fold -w2 | awk '{print "\\x" $1}' | tr -d '\n' && echo '"'
    done
}

#do it a bunch
function repeat() {
    local i max
    max=$1; shift;
    for ((i=1; i <= max ; i++)); do
        eval "$@";
    done
}
