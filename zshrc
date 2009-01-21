# /etc/zshrc: system-wide .zshrc file for zsh(1).
#
# This file is sourced only for interactive shells. It
# should contain commands to set up aliases, functions,
# options, key bindings, etc.
#
# Global Order: zshenv, zprofile, zshrc, zlogin

emulate zsh

[[ $UID = 0 ]] && umask 022 || umask 022

# {{{ hosts and users
if [ -d $HOME/.ssh ]
then
  hosts=(`cat $HOME/.ssh/known_hosts* | perl -pe 's/(^.*?)\s.*/$1/;s/,/\n/;undef $_ if /[:#]/' | sort | uniq`)
fi

#users=("davh")
# }}}

# {{{ Shell functions
setenv() { typeset -x "${1}${1:+=}${(@)argv[2,$#]}" }  # csh compatibility
freload() { while (( $# )); do; unfunction $1; autoload -U $1; shift; done }
# }}}

# {{{ Loading of functions
unalias run-help >/dev/null 2>&1 || true

# Where to look for autoloaded function definitions
fpath=($fpath ~/.zfunc)
typeset -U fpath

# Autoload all shell functions from all directories in $fpath 
# Assuming that they have all been precompiled with something like
# for i in ${(M)fpath:#/usr/share/zsh/$ZSH_VERSION*}; do 
# zcompile -U -M $i.zwc $i/*~*.zwc(^/) ; 
# chmod 644 $i.zwc ; 
# done
for func in $^fpath.zwc(N-.r:); autoload -U -w $func
# }}}

# {{{ colors
#if [ -e ~/.dircolors ]
#then
#eval `dircolors ~/.dircolors`
#else
#eval `dircolors`
#fi
#colors
# }}}

# {{{ setup Completions
zstyle ':completion:*' completer _oldlist _expand _complete _ignored #_match #_prefix
zstyle ':completion:*' verbose true
zstyle ':completion:*:expand:*' tag-order all-expansions
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters
zstyle ':completion:*:processes' command 'ps u'
zstyle '*' hosts $hosts
zstyle '*' users $users
zstyle ':completion:*:*:(^rm):*:*files' ignored-patterns '*?~' '*?.o' '*?.old' '*?.pro'
zstyle ':completion:*' ignore-parents parent directory
#zstyle ':completion:*' format '%B%d%b'
#zstyle ':completion:*:descriptions' format '%B%d%b'
#zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' match-original both
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'l:|=* r:|=*'
zstyle ':completion:*' max-errors 0
zstyle ':completion:*' squeeze-slashes true
#*#zstyle ':completion:*' use-compctl false
zstyle ':completion:*' use-cache true
zstyle ':completion:*' auto-description 'Specify: %d'
zstyle ':completion:*' list-colors  ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu select=2
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p. Line %l%s
zstyle ':completion:*' special-dirs '..'
#zstyle :compinstall filename '/home/disk10/davh/.compinstall'

# {{{ Load completion for rake
. ${HOME}/dotfiles/trunk/rake_completion.zsh
# }}}

autoload -U compinit
compinit -u

setopt BASH_AUTO_LIST NO_AUTO_MENU NO_LIST_AMBIGUOUS 
setopt LIST_TYPES LIST_BEEP NO_REC_EXACT 
# }}}

#recompile if changed
#zrecompile -p -R ~/.zshrc -- -M ~/.zcompdump

#We like emacs keys
bindkey -e

# {{{ Set up aliases
alias mv='nocorrect mv'       # no spelling correction on mv
alias cp='nocorrect cp'       # no spelling correction on cp
alias mkdir='nocorrect mkdir' # no spelling correction on mkdir
alias j=jobs
alias pu=pushd
alias po=popd
alias d='dirs -v'
alias h=history
alias psf='ps -ef --forest'
# List only directories and symbolic
# links that point to directories
alias lsd='ls -ld *(-/DN)'
# List only file beginning with "."
alias lsa='ls -ld .*'
#Standard BASH thing
alias ll='ls -l'
alias la='ls -lA'
alias l='ls -CF'
alias dir='ls --color=auto --format=vertical'
alias vdir='ls --color=auto --format=long'
# }}}

# {{{ Editor and viewer
set translation latin_1
set eight on

EDITOR=vi		# name of your default editor
PAGER=less		# name of your default pager
LESS=sqcM				# options for less
LESSEDIT="%E %f"
LESSCHARSET=latin1      #ae oe and aa are letters

# }}}

# {{{ xterm header
precmd() {
  print -nP "\e]0;%(!.%n@.)%m:%~\a"
}

preexec () {
  print -nP "\e]0;%(!.%n@.)%m:%~ : "
  print -nr "$1"
  print -nP "\a"
}

# }}}

# {{{ History stuff
HISTFILE=~/.zhistory
SAVEHIST=20000
HISTSIZE=20000
setopt APPEND_HISTORY INC_APPEND_HISTORY HIST_ALLOW_CLOBBER
setopt HIST_FIND_NO_DUPS HIST_IGNORE_ALL_DUPS HIST_SAVE_NO_DUPS
# }}}


# {{{ Other options
setopt AUTO_CD AUTO_PUSHD PRINT_EIGHT_BIT
setopt CHECK_JOBS NO_HUP EXTENDED_GLOB GLOB_DOTS
setopt LONG_LIST_JOBS  
setopt NOTIFY PUSHD_IGNORE_DUPS PUSHD_SILENT 
setopt RC_QUOTES SUN_KEYBOARD_HACK CLOBBER 

unsetopt bgnice FLOW_CONTROL HUP IGNORE_EOF 
#unsetopt autoparamslash

DIRSTACKSIZE=20

#NOBEEP
#Diku thinks this should be reversed. ARGH
#ZBEEP='\e[?5l\e[?5h'
#ZBEEP='\e[?5h\e[?5l'
READNULLCMD=${PAGER:-/usr/bin/pager}

bindkey ' ' magic-space    # also do history expansion on space
bindkey '^I' complete-word # complete on tab, leave expansion to _expand

# }}}


# {{{ Set prompt
prompt_setup () {
  local root_col=${1:-'red'}
  local norm_col=${1:-'cyan'}

  prompt_newline=$'\n%{\r%}'

  local root_color="%{$fg_no_bold[$root_col]%}"
  local norm_color="%{$fg_no_bold[$norm_col]%}"
  local pathr_color="%{$fg_no_bold[$root_col]%}"
  local pathn_color="%{$fg_no_bold[$norm_col]%}"
  local reset="%{$reset_color%}"

#  TRAPZERR () {
#    print -P "$fg_bold[red]ExitCode: %?$reset_color"
#  }

  PS1="%1(l.$prompt_newline.)%(!.$root_color.$norm_color)%n@%m%(!.#.$)$reset "
  RPS1=" %(!.$pathr_color.$pathn_color)%B%~%b$reset"  # prompt for right side of screen
}
prompt_setup
# }}}

export CVSUMASK="755"
alias ll='ls -al'
alias lenv='locomotive bash-environment'

# Environment for local software
export PATH=/Users/lj3/software/jruby-1.1.1/bin:/Users/lj3/software/bin:/usr/local/bin/:/usr/local/mysql/bin:/Users/lj3/software/instantclient10_1:/Users/lj3/software/ImageMagick-6.3.7/bin:$PATH
export LD_LIBRARY_PATH=/Users/lj3/software/lib
export PERL5LIB=/Users/lj3/perl/System/Library/Perl/5.8.6:/Users/lj3/perl/lib/perl5/site_perl:/Users/lj3/perl/lib/perl5/site_perl/5.8.6:/Users/lj3/software/perl/lib/perl5/site_perl

export DYLD_LIBRARY_PATH=/Users/lj3/software/instantclient10_1:/Users/lj3/software/ImageMagick-6.3.7/lib
export BSVN=svn+byssh://localhost/repos/svn/badger
export MAGICK_HOME="$HOME/software/ImageMagick-6.3.7"

# {{{ get local stuff... possibly overwrite
if [ -e ~/.zlocal ]
then
  zrecompile -p -R ~/.zlocal
  source ~/.zlocal
fi

# }}}

#export RAILS_ENV=offline
export RAILS_ENV=development

export http_proxy=http://localhost:3128/
export soap_use_proxy=on

# TextMate
export TM_SUPPORT_PATH 

