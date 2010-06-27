"Basic setup for all files {{{
set nocompatible "VIM over VI

filetype plugin indent on           "turn plugins/indent on
syntax on                           "Turn syntax highlighting on

set backspace=indent,eol,start      "Allow backspacing over everything in insert mode
set background=dark                 "Hint Vim that I use dark colorscheme

set confirm                         "Ask for confirmation rather then refuse certain commands
set cursorline                      "Turn on current line highlight
set expandtab                       "I want spaces instead of tabs
set fileencodings=ucs-bom,utf-8,latin2,default,latin1,default
set fileformats=unix,dos            "Type of <EOL> in written files
set formatoptions=croqw             "Automatic formatting settings
set hidden                          "Keep hidden windows
set history=1000                    "Keep 1000 lines of command line history
set ignorecase                      "Ignore case in search patterns
set laststatus=2                    "Always show statusbar
set lazyredraw                      "Don't update screen while executing macros

"set listchars=tab:▸⎯,eol:◦          "Strings to use in 'list' mode. list is off by default.
"set listchars=tab:▸⎯,eol:·          "Strings to use in 'list' mode. list is off by default.
"set listchars=tab:⇄·,eol:↵          "Strings to use in 'list' mode. list is off by default.
"set listchars=tab:▸⎯,eol:↲,trail:·  "Strings to use in 'list' mode. list is off by default.
set listchars=tab:▸⎯,trail:·  "Strings to use in 'list' mode. list is off by default.
set number                          "show line numbers
"set ruler                           "Show the cursor position all the time
set rulerformat=%l,%c%V%=#%n\ %3p%% "Content of the ruler string
"set statusline=%<%F\ %h%m%r%=%-14.(%l,%c%V%=#%n\ %3p%%)\ %P
"set statusline=%<%F\ %h%m%r%=%-14.(%l,%c%V%)\ #%n\ %3p%%
set scrolloff=5                     "Minimal number of screen lines to keep above and below the cursor
set selection=exclusive             "Define the behavior of the selection

set sessionoptions-=blank           "Don't store empty windows
set sessionoptions-=globals         "Don't store global vars
set sessionoptions-=localoptions    "Don't store local options and mappings
set sessionoptions-=options         "Don't store options and mappings
set shiftwidth=4                    "Number of spaces to use for each step of (auto)indent
set shortmess=atToOI                "Abbreviate some messages
set showbreak=>                     "String to put at the start of lines that have been wrapped
set showcmd                         "Show (partial) command in status line
set showmatch                       "When a bracket is inserted, briefly jump to the matching one
"set smartindent                     "Do smart autoindenting when starting a new line
filetype indent on                  "Indenting per filetype rather then smartindent.
set smarttab                        "Do the smart tab/backspace behaviour
set softtabstop=4

"spell options
set spelllang=pl,en
set spellfile=/home/gryf/.vim/pol.utf8.add

set splitbelow                      "Create new window below current one
set swapfile                        "Use swap file
set t_vb=                           "Turn beeping off
set tabstop=4                       "Set tab stop to 4
set updatecount=50                  "After typing this many chars the swap file will be written to disk
set viewoptions-=options            "Don't store options in view stored in ~/.vim/view dir
set viminfo='20,\"50                "Configure .viminfo
set whichwrap+=<,>,[,]              "Cursor keys wrap to previous/next line
set wildchar=<TAB>                  "Character to start wildcard expansion in the command-line
set wildmenu                        "Put command-line completion in an enhanced mode
set wrapmargin=1                    "Number of characters from the right window border where wrapping starts

"backup/writeback/swapfile
set nobackup
set nowb
set noswapfile
"in case they are needed, store swapfiles in tmp
"set dir=~/tmp/

" TOhtml options
:let html_number_lines = 1
:let html_use_css = 1
:let html_ignore_folding = 1
:let html_use_encoding = "utf-8"
"}}}
"PYTHON: specific vim behaviour for Python files {{{
"
"remove all trailing withitespace for python before write
autocmd BufWritePre *.py :call <SID>StripTrailingWhitespaces()
autocmd BufWritePre *.rst :call <SID>StripTrailingWhitespaces()
autocmd BufWritePre *.wiki :call <SID>StripTrailingWhitespaces()
autocmd BufWritePre *.js :call <SID>StripTrailingWhitespaces()
autocmd BufWritePre *.css :call <SID>StripTrailingWhitespaces()
autocmd BufWritePre *.xml :call <SID>StripTrailingWhitespaces()
"autocmd BufWritePre *.py :!message.py '%'
"Load views for py files
autocmd BufWinLeave *.py mkview
autocmd BufWinEnter *.py silent loadview

"Set python custom editor behaviour. Note, smartindent is not recommended for
"python files!
autocmd FileType python set tabstop=4|set softtabstop=4|set shiftwidth=4
autocmd FileType python set expandtab|set smarttab|set noautoindent
autocmd FileType python set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class,with
autocmd FileType python set foldmethod=indent|set foldlevel=100|set list|set textwidth=78|set cinkeys-=0#
autocmd FileType python set indentkeys-=0#|inoremap # X<BS>#
"autocmd FileType python set ofu=syntaxcomplete#Complete
autocmd FileType python compiler pylint
let g:pylint_onwrite = 0 " I don't want to run pylint on every save

"autocmd FileType python setlocal omnifunc=pysmell#Complete
let python_highlight_all=1
" }}}
" OTHER FILES: {{{
"autocmd FileType python :!echo '%'
autocmd FileType sql set nolist|set nosmartindent|set autoindent|set foldmethod=manual
autocmd FileType vim set nolist|set nosmartindent|set autoindent|set foldmethod=manual
autocmd FileType snippet set nolist|set tabstop=4|set autoindent|set foldmethod=manual|set noexpandtab|set shiftwidth=4
autocmd FileType snippets set noexpandtab, nolist
autocmd FileType rst set spf=/home/gryf/.vim/pol.utf8.add|set textwidth=80

"}}}
"LaTeX: option for LaTeX files {{{
autocmd FileType tex compiler rubber|map <F5> :make<cr>
"}}}
"TERMINAL: options for terminal emulators {{{
if $TERM == 'rxvt-unicode' || $TERM == 'xterm'
    set t_Co=256                    "Enable 256 colors support
    set term=rxvt-unicode256        "Set terminal type
    "repair urxvt ctrl+pgup/down behaviour
    map [5^ <C-PageUp>
    map [6^ <C-PageDown>
endif
if $TERM == 'linux'
    "For term like linux terminal keep interface simple
    set nolist
    set nocursorline
    set nonumber
endif
"}}}
"PLUGINS: {{{
"getscriptPlugin {{{2
"let g:GetLatestVimScripts_allowautoinstall=1  "allow autoinstall scripts
"}}}
"TagList{{{2
let Tlist_Use_Right_Window = 1
"show menu in gvim. usefull to pop it up from kbd
let Tlist_Show_Menu = 1
let Tlist_Auto_Open = 0
let Tlist_Display_Prototype = 1
"open fold for current buff, and close all others...
let Tlist_File_Fold_Auto_Close = 1
".. or just display current file
"let Tlist_Show_One_File = 1
let Tlist_Sort_Type = "name"
let Tlist_Exit_OnlyWindow = 1
let Tlist_WinWidth = 40
"}}}
"NERDTree {{{2
let NERDTreeWinSize = 40
" }}}
"VimWIKI {{{2
let g:vimwiki_list = [{'html_header': '~/vimwiki/vimwiki_head.tpl',
                      \ 'html_footer': '~/vimwiki/vimwiki_foot.tpl'}]
" }}}
"FuzzyFinder {{{2
let g:fuf_file_exclude = '\v\~$|\.(o|bak|swp|pyc|pyo|pyd)$|(^|[/\\])\.(hg|git|bzr|cvs)($|[/\\])'
"}}}
"ShowMarks {{{2
let g:showmarks_ignore_type = "hqprm"
let g:showmarks_include = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
"}}}
"jsbeautify {{{3
nnoremap <silent> <leader>ff :call g:Jsbeautify()<cr>:retab!<cr>
"}}}
" pydiction {{{2
let g:pydiction_location = '/home/gryf/.vim/after/ftplugin/pytdiction/complete-dict'
"}}}
"TagListToo {{{2
let g:VerticalToolWindowSide = 'right'
"}}}
"}}}
"KEYS: User definied keyboard shortcuts {{{

"set <C-F1>=^[[11^
"set <S-F1> = ^[[23~
"nmap <TAB> :bnext<CR>
"nmap <S-F1> :split<CR>
"nmap <C-F1> :vsplit<CR>

"Cycle through buffers.
map <C-p> :bp<CR>
map <C-n> :bn<CR>
"map <C-PageUp> :bp<CR>
"map <C-PageDown> :bn<CR>

"Cycle through tabs.
if $TERM == 'rxvt-unicode'
    map <C-PageDown> :tabn<CR>
    map <C-PageUp> :tabp<CR>
endif

map <F5> :call <SID>runPyLint()<cr>
map <F6> :call <SID>PyLintBuf()<cr>

"map ctags plugin to show popup menu in gvim
"map <F6> :popup Tags<CR>

"QuickFix jumps
map <F9> :cp<CR>
map <F10> :cn<CR>
map <F11> :lprevious<CR>
map <F12> :lnext<CR>
map <S-F9> :QFix<CR>
map <S-F11> :LWin<CR>
map <S-F12> :call ToggleQFonValidate()<CR>

"remove trailing whitespaces
map <C-e> :%s/\s\+$//<CR>

"redefine tab key for vimwiki
map <Leader>wn <Plug>VimwikiNextWord
map <Leader>wp <Plug>VimwikiPrevWord
map ]b :call OpenInFirefox()<cr>

"make displaying tags easy
nmap <Leader>t :TlistToo<CR>
"aswell minibufexplorer
"map <Leader>b :TMiniBufExplorer<CR><CR>
"eclim Buffer shortcut
map <Leader>b :Buffers<CR>

" copy current buffer filename (full path)
nmap ,cn :silent call <SID>CopyFileName(1)<CR>
" copy current buffer filename (filename only)
nmap ,cs :silent call <SID>CopyFileName(0)<CR>

"FuzzyFinder plugin. Keys for file fuf
map <C-F> :FufFile **/<CR>
" }}}
" FUNCTIONS: usefull functions for all of th files {{{
"Sessions
"autocmd VimEnter * call LoadSession()
"autocmd VimLeave * call SaveSession()
"
"function! SaveSession()
"    execute 'mksession!'
"endfunction
"
"function! LoadSession()
"    if argc() == 0
"        execute 'source Session.vim'
"    endif
"endfunction

function <SID>runPyLint()
    echohl Statement
    echo "Running pylint (ctrl-c to cancel) ..."
    echohl Normal
    :Pylint
endfunction
function <SID>PyLintBuf()
    echohl Statement
    echo "Running pylint (ctrl-c to cancel) ..."
    echohl Normal
    let file = expand('%:p')
    let cmd = 'pylint --reports=n --output-format=text "' . file . '"'

    if has('win32') || has('win64')
        let cmd = 'cmd /c "' . cmd . '"'
    endif
    
    exec "bel silent new " . file . ".lint"
    exec "silent! read! " . cmd
endfunction

function! <SID>StripTrailingWhitespaces()
    " Preparation: save last search, and cursor position.
    let _s=@/
    let l = line(".")
    let c = col(".")
    " Do the business:
    %s/\s\+$//e
    " Clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
endfunction

function <SID>CopyFileName(full)
    if a:full
        let l:full_fn = expand("%:p")
    else
        let l:full_fn = expand("%")
    endif

    " Convert slashes to backslashes for Windows.
    if has('win32')
        let @*=substitute(l:full_fn, "/", "\\", "g")
    else
        let @*=l:full_fn
    endif
    echo l:full_fn + " copied to clipboard"
endfunction

command -bang -nargs=? QFix call QFixToggle(<bang>0)
function! QFixToggle(forced)
  if exists("g:qfix_win") && a:forced == 0
    cclose
    unlet g:qfix_win
  else
    copen 10
    let g:qfix_win = bufnr("$")
  endif
endfunction

command -bang -nargs=? LWin call LocationWindowToggle(<bang>0)
function! LocationWindowToggle(forced)
  if exists("g:loc_win") && a:forced == 0
    lclose
    unlet g:loc_win
  else
    lopen 10
    let g:loc_win = bufnr("$")
  endif
endfunction

" OpenInFirefox
" try to open url in Firefox
function! OpenInFirefox()
    let l:line = getline(".")
    let l:cursor_position = getpos(".")[2]
    let l:url = ""
    let l:pattern = '\c\%(http[s]\?\|ftp\|file\)\:\/\/[^$ ]\+'

    for i in split(l:line)
        if match(i, l:pattern) == 0
            "check position in line against cursor_position
            for x in range(match(l:line, i), match(l:line, i) + len(i))
                if l:cursor_position == x
                    let l:url = i
                    break
                endif
            endfor
        endif
    endfor

    if len(l:url) > 0
        call system("firefox " . l:url)
        echohl Statement
        echo "Opened '" . l:url ."' in firefox."
    else
        echohl WarningMsg
        echo "Not an URL under cursor."
    endif
    echohl None
endfunction

"}}}
" GUI: here goes all the gvim customizations {{{
if has('gui_running')
    "set guifont=Consolas\ 12  "I like this font, but it looks like crap on linux
    "set listchars=tab:▸⎼,eol:↲ "Strings to use in 'list' mode. this is different from console fixed-misc font. 
    set guifont=Fixed\ 14      "I like this font better.
    set mouse=a                "Enable mouse support
    set guioptions-=T          "No toolbar
    "add menuitem OpenInFirefox
    nmenu 666 PopUp.&Open\ in\ browser :call OpenInFirefox()<cr>
    "Turn off annoying beep
    au GUIEnter * set vb t_vb=
endif
"}}}
" HIGHLIGHT: colorscheme and highlight, which should be applyed on after {{{
" some vim initialization
if $TERM == 'linux'
    colorscheme pablo
else
    colorscheme wombat256grf
endif

"highlight code beyond 79 column (must be after colorscheme)
highlight OverLength ctermbg=black guibg=black
match OverLength /\%81v.*/
"}}}
" vim:ts=4:sw=4:wrap:fdm=marker:
