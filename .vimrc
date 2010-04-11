" gvim settings:
"
"set guifontset=-misc-fixed-medium-r-normal-*-*-120-*-*-c-*-iso8859-2
"set guifont=-misc-fixed-medium-r-normal-*-*-120-*-*-c-*-iso8859-2
"set mouse=a
"set guifontset="Monospace 13"
"set guifont="Monospace 13"
"colorscheme pablo


" vim setting:
" 
set bg=dark
"
"       VIM configuration file
"    Author: Piotr Debicki (pdebicki@poczta.onet.pl)
""""""""
"
"  Always set autoindenting on
"
 set autoindent
"
"  Automatically save modifications to files when
"  using critical commands
"
 set autowrite
"
"  Allow backspacing over everything in insert mode
"
 set backspace=2
"
"  Don't make a backup before overwriting
"
 set nobackup
"
"  Reset cinwords - this suxx with smartindent
"
 set cinwords=
"
"  Use Vim settings, rather then Vi settings
"
 set nocompatible
"
"  Ask for confirmation rather then refuse certain commands
"
 set confirm
"
"  Type of <EOL> in written files
"
 set fileformats=unix,dos
"
"  Automatic formatting settings
"
 set formatoptions=croq
"
"  Keep hidden windows
"
 set hidden
"
"  Keep 50 lines of command line history
"
 set history=50
"
"  Don't highlight search patterns
"
 set nohlsearch
"
"  Ignore case in search patterns
"
 set ignorecase
"
"  Always show statusbar
"
 set laststatus=2
"
"  Don't update screen while executing macros
"
 set lazyredraw
"
"  Strings to use in 'list' mode
"
 set listchars=tab:>-,trail:-,eol:$
"
"  Show the cursor position all the time
"
 set ruler
"
"  Content of the ruler string
"
 set rulerformat=%l,%c%V%=#%n\ %3p%%
"
"  Minimal number of lines to scroll when the cursor gets off the screen
"
" set scrolljump=1
"
"  Minimal number of screen lines to keep above and below the cursor
"
 set scrolloff=3
"
"  Define the behavior of the selection
"
 set selection=exclusive
"
"  Name of the shell to use for ! and :! commands
"
" set shell=[3mbin[0mbash
"
"  Number of spaces to use for each step of (auto)indent
"
 set shiftwidth=4
"
"  Abbreviate some messages
"
 set shortmess=atToOI
"
"  String to put at the start of lines that have been wrapped
"
 set showbreak=>
"
"  Show (partial) command in status line
"
 set showcmd
"
"  When a bracket is inserted, briefly jump to the matching one
"
 set showmatch
"
"  Do smart autoindenting when starting a new line
"
 set smartindent
"
"  Create new window below current one
"
 set splitbelow
"
"  Use swap file
"
 set swapfile
"
"  Turn beeping off
"
 set t_vb=
"
"  Set tab stop to 4
"
 set tabstop=4
"
"  Turn off scrolling -> faster
"
" set ttyscroll=0
"
"  After typing this many chars the swap file will be written to disk
"
 set updatecount=50
"
"  Configure .viminfo
"
 set viminfo='20,\"50
"
"  Cursor keys wrap to previous/next line
"
 set whichwrap+=<,>,[,]
"
"  Character to start wildcard expansion in the command-line
"
 set wildchar=<TAB>
"
"  Put command-line completion in an enhanced mode
"
 set wildmenu
"
"  Turn line wrapping off (a ja chcê wrap)
"
" set nowrap
"
"  Number of characters from the right window border where wrapping starts
"
 set wrapmargin=1
"
"  Turn syntax highlighting on
"
 syntax on

"
"  wgrywaj równie¿ widoki dla plików php
"
 
 au BufWinLeave *.php mkview
 au BufWinEnter *.php silent loadview
 
"
" ============================
"        Abbreviations
" ============================
"
"  Some C abbreviations
"
 iab  Zmain  int main(int argc, char *argv[])
 iab  Zinc  #include
 iab  Zdef  #define
"
"  Some other abbreviations
"
 iab  Zdate  <C-R>=strftime("%y%m%d")<CR>
 iab  Ztime  <C-R>=strftime("%H:%M:%S")<CR>
 iab  Zmymail pdebicki@poczta.onet.pl
 iab  Zmyphone 0 502 935 242
 iab  Zfilename <C-R>=expand("%:t:r")<CR>
 iab  Zfilepath <C-R>=expand("%:p")<CR>
"
" ============================
"        Customization
" ============================
"
"  Function keys
"
 nmap <F1> 3K
 nmap <F5> :cnext<CR>
 nmap <F6> :cprevious<CR>
 nmap <F7> :clist<CR>
 nmap <F9> :make<CR>
 nmap <F10> :!!<CR>
 nmap <F11> :call SwitchTabstop()<CR>
 nmap <F12> :call SwitchSyntax()<CR>
 nmap <F2> :call SwitchIndent()<CR>
 imap <F1> <ESC>3Ki
 imap <F5> <ESC>:cnext<CR>
 imap <F6> <ESC>:cprevious<CR>
 imap <F7> <ESC>:clist<CR>
 imap <F9> <ESC>:make<CR>
 imap <F10> <ESC>:!!<CR>
 imap <F11> <ESC>:call SwitchTabstop()<CR>i
 imap <F12> <ESC>:call SwitchSyntax()<CR>i
 imap <F2> <ESC>:call SwitchIndent()<CR>i
"
"  Show next buffer
"
 nmap <TAB> :bnext<CR>
"
"  Execute shell commands easier
"
 nmap !  :!
"
"  Align line
"
 nmap ,ac :center<CR>
 nmap ,al :left<CR>
 nmap ,ar :right<CR>
"
"  Print the ASCII value of the character under the cursor
"
 nmap ,as :ascii<CR>
"
"  Change type of <EOL> - unix/dos
"
 nmap ,eol :call ChangeFileFormat()<CR>
"
"  Insert C/C++ source footer
"
 nmap ,fo :%r $HOME/src/TEMPLATE/FOOTER<CR>
"
"  Insert C/C++ source header
"
 nmap ,he :0r $HOME/src/TEMPLATE/HEADER<CR>
"
"  Turn highlight search on/off
"
 nmap ,hs :call ToggleOption('hlsearch')<CR>
"
"  Turn line numbers on/off
"
 nmap ,nu :call ToggleOption('number')<CR>
"
"  Remove all empty lines
"
 nmap ,re :g/^$/d<CR>
"
"  Edit .vimrc
"
 nmap ,rc :n $HOME/.vimrc<CR>
"
"  Turn line wrapping on/off
"
 nmap ,wr :call ToggleOption('wrap')<CR>
"
"  Show white spaces on/off
"
 nmap ,ws :call ToggleOption('list')<CR>
"
"  Make selection lowercase
"
 vmap ,l  u
"
"  Rot13 encode selection
"
 vmap ,r  g?
"
"  Make selection switch case
"
 vmap ,s  ~
"
"  Make selection uppercase
"
 vmap ,u  U
" 
" tym, oto, skrótem komentuj/unkomentuj ca³e linie, bloki, etc.
" niezbêdny plugin enhcommentify w ~/.vim/plugin
"
nmap <C-a> :call EnhancedCommentify('', 'guess')<CR>j
vmap <C-a> :call EnhancedCommentify('', 'guess')<CR>j

"
" ============================
"          Functions
" ============================

function ToggleOption (option)
 execute 'set ' . a:option . '!'
 execute 'echo "' . a:option . ':" strpart("OFFON",3*&' . a:option . ',3)'
endfunction

function ChangeFileFormat()
 if &fileformat == "unix"
  set fileformat=dos
  echo "<EOL> type: DOS"
 else
  set fileformat=unix
  echo "<EOL> type: UNIX"
 endif
endfunction

function SwitchTabstop()
 if &tabstop == 4
  set tabstop=8
  echo "Tabstop = 8"
 else
  set tabstop=4
  echo "Tabstop = 4"
 endif
endfunction

function SwitchSyntax()
 if has("syntax_items")
  syntax off
  echo "Syntax highlighting OFF"
 else
  syntax on
  echo "Syntax highlighting ON"
 endif
endfunction

function SwitchIndent()
 if &autoindent 
  set noautoindent
  set nosmartindent
  set formatoptions=
  echo "Indent OFF"
 else
  set autoindent
  set smartindent
  set formatoptions=croq
  echo "Indent ON"
 endif
endfunction

" vim:ts=4:sw=4:wrap:
" - EOF -



