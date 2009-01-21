" Set Vim
" An example for a gvimrc file.
" The commands in this are executed when the GUI is started.
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.gvimrc
"             for Amiga:  s:.gvimrc
"  for MS-DOS and Win32:  $VIM\_gvimrc

" Make external commands work through a pipe instead of a pseudo-tty
"set noguipty
set vb

" Automatically reload .vimrc when changing
autocmd! bufwritepost .vimrc source %

" Get Backspace working corectly
"set t_kb=^V<BS>
fixdel

" set the X11 font to use
"set font=-misc-fixed-medium-r-normal--10-130-75-75-c-70-iso8859-1
"set font=-misc-*-*-*-*-*-10-*-*-*-*-*-*-*
"set font=6x10

" Make command line two lines high
set ch=2

" Don't indent pastes
"set paste

" Vi compatebility flags
set cpoptions="aABceFs"

" Set X11 font
set guifont=6x10

" What will be shown on the commandline
set shm="aAI"

" Matching chars
"set mps=(:),{:},[:],<:>

" Show (partial) command in status line.  
" set showcmd

" Ignore caseing in search
set ignorecase

" Ignore ignorecase if cased :)
set smartcase

" Use `cindent
" set smartindent

" File formats
set fileformats="unix,dos,mac"

" Use <Tab> to complete
set wildchar=<Tab>

" Completion mode
set wildmode=list:longest

" Backspace over insert start
set backspace=2

" hmm..
" set cindent

" No menubar, no scrollbar .. no nothing!
set guioptions=agi

" history in cmd
set history=20

" Cool jumpsearch thing.. 
set incsearch

" Where am I
set ruler

" To read .profile
set shell=zsh\ -l

" Slow display
"set scrolljump=20

" Statusline on all windows
"set laststatus=2
" Now we only want it if there is more than one window
set laststatus=1

" Can hidde buffers without closing them
set hidden

" Don't lave the backup files floating around on the disc
set backupdir=/tmp/

" Backup are for wips
set nobackup

" Swapdir
set dir=/tmp/

" Dont backup
set backup

" Match brackets and so on...
set showmatch

"set title titlestring=%<%f%=[%l/%L]\ [%02c%03V]\ %P

" Check for CVS
"so $VIM/vim54/cvs.vim

" Statusline deluxe
set statusline=[%n]\ %<%f\ %((%1*%M%*%R%Y)%)\ %=%-19(\LINE\ [%3l/%3L]\ COL\ [%02c%03V]%)\ ascii['%02b']\ %P

" Small tabs
set ts=4
set sw=4
set expandtab
"set noai

" spell checker 
" map <C-K><C-K> :w!<CR>:!xterm -e ispell -S % <CR>:e!<CR><CR>

" Make shift-insert work like in Xterm
"set mousemodel=extend
" map <S-Insert> <MiddleMouse>
" map! <S-Insert> <MiddleMouse>
" No help on F1 
map  <f1>   <nop>
map! <f1>   <nop>
map  <help> <nop>
map! <help> <nop>

"autocmd BufNewFile * :r ~/.vim/template.%:e

" Spell checking
"set spell

" Only do this for Vim version 5.0 and later.
if version >= 500

  " I like highlighting strings inside C comments
  let c_comment_strings=0

  " Switch on syntax highlighting.
  "set background=dark
  syntax on
  filetype plugin indent on

  " Switch on search pattern highlighting.
  set hlsearch

  " Hide the mouse pointer while typing
  set mousehide
  " Dont move the cursor with the mouse
  " set mouse=""

  " Read the syntax file
  "so $VIM/syntax/syntax.vim

  " Set nice colors
  " background for normal text is light grey
  " Text below the last line is darker grey
  " Cursor is green
"  highlight Normal guibg=black guifg=white
 " highlight Cursor guibg=Green guifg=NONE
 " highlight NonText guibg=black
  highlight StatusLine ctermbg=Yellow ctermfg=Red gui=NONE
  highlight StatusLineNC ctermfg=NONE ctermfg=Red guibg=Yellow guifg=Red
  highlight User1 ctermbg=Red ctermfg=Yellow
  highlight Search guibg=Yellow guifg=black 
  "highlight Special gui=NONE guibg=grey95

endif

au! BufRead,BufNewFile *.yaml,*.yml  setfiletype yaml

" i hate typing this word
"ab syn synchronize

let g:no_omni_filetypes = ['ruby']
function! Tab_Or_Complete() 
  " next entry in popup menu
  if pumvisible()
    return "\<c-N>"
  endif
  " if not on whitespace
  if strpart( getline('.'), 0, col('.')-1 ) =~ '^\s*$' 
    return "\<Tab>"
   elseif count(g:no_omni_filetypes, &filetype) == 0 && exists('&omnifunc') && &omnifunc != '' 
    return "\<C-X>\<C-O>"
  else 
    return "\<C-N>"
  endif 
endfunction 

" Doesn't work if paste is set. Since it will ignore tab
inoremap <silent> <tab> <c-r>=Tab_Or_Complete()<cr>

"let g:rubycomplete_buffer_loading = 1

au FileType mail set spell

"set sessionoptions=blank,buffers,curdir,folds,help,resize,tabpages,winsize
" map <c-q> :mksession! ~/.vim/.session <cr>

au VimLeave * call VimLeave()
au VimEnter * call VimEnter()

let g:PathToSessions = $HOME . "/.vim/sessions/"

function! VimEnter()
   if argc() == 0
      " gvim started with no files
      if has("browse") == 1
         let g:SessionFileName = browse(0, "Select Session", g:PathToSessions, g:PathToSessions . "LastSession.vim")
         if g:SessionFileName != ""
            exe "source " . g:SessionFileName
         endif
      else
         " For non-gui vim
         let LoadLastSession = confirm("Restore last session?", "&Yes\n&No")
         if LoadLastSession == 1
            exe "source " . g:PathToSessions . "LastSession.vim"
         endif
      endif
   endif
endfunction

function! VimLeave()
   exe "mksession! " . g:PathToSessions . "LastSession.vim"
   if exists("g:SessionFileName") == 1
      if g:SessionFileName != ""
         exe "mksession! " . g:SessionFileName
      endif
   endif
endfunction

" A command for setting the session name
com! -nargs=1 SetSession :let g:SessionFileName = g:PathToSessions . <args> . ".vim"
" .. and a command to unset it
com! -nargs=0 UnsetSession :let g:SessionFileName = ""

" map <c-s> :source ~/.vim/.session <cr>

" For rails plugin
command! -bar -nargs=1 OpenURL :!open <args>
