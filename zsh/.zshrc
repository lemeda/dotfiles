# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=100000
setopt appendhistory beep extendedglob nomatch notify
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/lena/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Bind keys
bindkey "${terminfo[khome]}" beginning-of-line
bindkey "${terminfo[kend]}" end-of-line
bindkey "\e[3~" delete-char
bindkey "\e[5~" beginning-of-history
bindkey "\e[6~" end-of-history

### Keyboard map
#setxkbmap fr

### Prompt
autoload -U promptinit
promptinit
autoload -U colors && colors

PROMPT="%{$fg_bold[magenta]%}%n%{$reset_color%}@%{$fg_no_bold[blue]%}%m %{$reset_color%}%~ %{$reset_color%}%# "

##
export EDITOR=vim

### Aliases
alias netn="sudo netctl start "
alias netsw="sudo netctl switch-to "
alias net-reset-mac-eno1="ip link set dev eno1 address 8c:dc:d4:7b:91:f2"
alias net-spoof-mac-eno1="ip link set dev eno1 address"
alias backlight="xbacklight -set "
alias ls="ls -la --color=auto"
alias :wq="exit"
alias music2mirage="pax11publish -e -S mirage"
#alias 2sleep="systemctl suspend & i3lock -u -i lemeda/Pictures/Wallpapers/Archlinux.png"
# → moved to rc.lua
alias i3lock="i3lock -u -i lemeda/Pictures/Wallpapers/Archlinux.png"
alias bépo="setxkbmap fr"
alias azer="setxkbmap fr bepo"
alias steam="LD_PRELOAD='/usr/$LIB/libstdc++.so.6 /usr/$LIB/libgcc_s.so.1 /usr/$LIB/libxcb.so.1 /usr/$LIB/libgpg-error.so' steam"
alias steam_unbreak_update='find ~/.steam/root/ \( -name "libgcc_s.so*" -o -name "libstdc++.so*" -o -name "libxcb.so*" -o -name "libgpg-error.so*" \) -print -delete'
alias nvidia-settings="optirun -b none nvidia-settings -c :8"
alias poezio="source ~/virtualenvs/poezio2/bin/activate ; ~/virtualenvs/poezio2/bin/poezio"
#alias skype='xhost +local: && su skype -c skype'
#alias skype='xhost +si:localuser:skype: && sudo -u skype /usr/bin/skype'
#alias -g clang++="clang++ -std=c++14 -Wall -Wextra -Wpedantic"
# → replaced by function (see below)
# alias start-VM="sudo systemctl start systemd-modules-load.service"
# → replaced by function (see below)
### End of aliases

### Starting VM-related modules
start-vm() {
    command sudo modprobe -a vboxdrv vboxnetadp vboxnetflt vboxpci
}

### Compiling-with-clang++ function
clang++() {
    if [[ $1 == "-osef" ]] ; then
        command clang++ ${@:2}
    else
        command clang++ -std=c++14 -Wall -Wextra -Wpedantic $@
    fi
}

### Add color to man pages
man() {
    env LESS_TERMCAP_mb=$(printf "\e[1;35m") \
        LESS_TERMCAP_md=$(printf "\e[1;34m") \
        LESS_TERMCAP_me=$(printf "\e[0m") \
        LESS_TERMCAP_se=$(printf "\e[0m") \
        LESS_TERMCAP_so=$(printf "\e[40;37m") \
        LESS_TERMCAP_ue=$(printf "\e[0m") \
        LESS_TERMCAP_us=$(printf "\e[32m") \
        man "$@"
}

export PATH=/usr/share/intellij-idea-ultimate-edition/bin/:$PATH
