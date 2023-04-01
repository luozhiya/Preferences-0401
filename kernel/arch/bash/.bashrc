#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

##################
# Init
##################
goforit() {
cd ~/Omega/script
./mount.sh
wmctrl -r :ACTIVE: -t 2 
./fastgithub.sh
}

##################
# PATH
##################
export PATH="${PATH}:/home/yanchcore/Omega/inpath/"

##################
# Rust
##################

. "$HOME/.cargo/env"
export RUSTUP_DIST_SERVER="https://rsproxy.cn"
export RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"

##################
# Proxy
##################

proxyassign(){
   PROXY_ENV="http_proxy ftp_proxy https_proxy all_proxy HTTP_PROXY HTTPS_PROXY FTP_PROXY ALL_PROXY"
   for envar in $PROXY_ENV
   do
      export $envar=$1
   done
   for envar in "no_proxy NO_PROXY"
   do
      export $envar=$2
   done
}

proxyclr(){
    PROXY_ENV="http_proxy ftp_proxy https_proxy all_proxy HTTP_PROXY HTTPS_PROXY FTP_PROXY ALL_PROXY"
    for envar in $PROXY_ENV
    do
       unset $envar
    done
}

proxyfg(){
   proxy_value="http://127.0.0.1:38457"
   no_proxy_value="localhost,127.0.0.1,LocalAddress,LocalDomain.com"
   proxyassign $proxy_value $no_proxy_value
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
