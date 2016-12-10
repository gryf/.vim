"Basic setup for all files {{{
set nocompatible                    "VIM over VI

" vimplug conf {{{

call plug#begin('~/.vim/bundle')

Plug 'Rykka/riv.vim'
Plug 'SirVer/ultisnips'
Plug 'Valloric/MatchTagAlways'
Plug 'davidhalter/jedi-vim'
Plug 'ervandew/taglisttoo'
Plug 'fs111/pydoc.vim'
Plug 'gryf/mark'
Plug 'gryf/pythonhelper'
Plug 'gryf/tagbar', {'branch': 'show_tag_kind2'}
Plug 'gryf/pep8-vim'
Plug 'gryf/pylint-vim'
Plug 'gryf/zoom.vim'
Plug 'hallison/vim-markdown'
Plug 'honza/vim-snippets'
Plug 'https://repo.or.cz/r/vcscommand.git'
Plug 'kazuyukitanimura/jsbeautify'
Plug 'kien/ctrlp.vim'
Plug 'mattn/calendar-vim'
Plug 'mduan/python.vim'
Plug 'mikeage/occur.vim'
Plug 'mileszs/ack.vim'
Plug 'myhere/vim-nodejs-complete'
Plug 'othree/html5.vim'
Plug 'pangloss/vim-javascript'
Plug 'pcaro90/jpythonfold.vim'
Plug 'rust-lang/rust.vim'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/syntastic'
Plug 'sjl/gundo.vim'
Plug 'skammer/vim-css-color'
Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'vim-scripts/JavaScript-Indent'
Plug 'vim-scripts/LanguageTool'
Plug 'vim-scripts/MatchTag'
Plug 'vim-scripts/Python-2.x-Standard-Library-Reference'
Plug 'vim-scripts/ShowMarks'
Plug 'vim-scripts/indentpython'
Plug 'vim-scripts/loremipsum'
Plug 'vim-scripts/mako.vim'
Plug 'vim-scripts/mako.vim--Torborg'
Plug 'vimwiki/vimwiki'
Plug 'will133/vim-dirdiff'
Plug 'yegappan/grep'

"in development
Plug '~/Devel/vim/kickass-vim/'

call plug#end()
" }}}

filetype plugin indent on           "turn plugins/indent on
syntax on                           "Turn syntax highlighting on

set backspace=indent,eol,start      "Allow backspacing over everything in insert mode
set background=dark                 "Hint Vim that I use dark colorscheme

set confirm                         "Ask for confirmation rather then refuse certain commands
set cursorline                      "Turn on current line highlight
set hlsearch                        "Turn on highlighting search text by default
set ignorecase                      "Be case insensitive...
set smartcase                       "but be case aware when needed
set expandtab                       "I want spaces instead of tabs
set fileencodings=ucs-bom,utf-8,latin2,default,latin1,default
set fileformats=unix,dos            "Type of <EOL> in written files
set formatoptions=croqw             "Automatic formatting settings
set hidden                          "Keep hidden windows
set history=1000                    "Keep 1000 lines of command line history
set laststatus=2                    "Always show statusbar
set lazyredraw                      "Don't update screen while executing macros
try
    set listchars=tab:▸―,trail:·    "Strings to use in 'list' mode. list is off by default.
catch /E474:/
    set listchars=tab:>-,trail:.    "Failsafe for Windows and non-unicode envs
endtry
set number                          "show line numbers

" Show ruler and set format of statusline
set ruler
set statusline=%<%F                 " filename (fullpath)
set statusline+=\ %h                " indicator for help buffer
set statusline+=%m                  " modified flag
set statusline+=%r                  " readonly flag
set statusline+=\ %{tagbar#currenttag('%s','','f')} " current tag
set statusline+=\ %{tagbar#currenttagtype('(%s)','')} " current tag type
set statusline+=%=                  " switch to the right
set statusline+=%(%l,%c%V%)         " line, column and virtual column
set statusline+=\ %3p%%             " percentage of the file

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
filetype indent on                  "Indenting per filetype rather then smartindent.
set smarttab                        "Do the smart tab/backspace behaviour
set softtabstop=4

"spell options
set spelllang=pl,en
let &spellfile=expand('$HOME/.vim/pol.utf8.add')

set splitbelow                      "Create new window below current one
set swapfile                        "Use swap file
set t_vb=                           "Turn beeping off
set tabstop=4                       "Set tab stop to 4
set updatecount=50                  "After typing this many chars the swap file will be written to disk
set viewoptions-=options            "Don't store options in view stored in ~/.vim/view dir
set viminfo='20,<1000,h,f0          "Configure .viminfo
set whichwrap+=<,>,[,]              "Cursor keys wrap to previous/next line
set wildchar=<TAB>                  "Character to start wildcard expansion in the command-line
set wildmenu                        "Put command-line completion in an enhanced mode
set wrapmargin=1                    "Number of characters from the right window border where wrapping starts

set textwidth=78
set colorcolumn=+1

"backup/writeback/swapfile
set nobackup
set nowb
set noswapfile
"in case they are needed, store swapfiles in tmp
"set dir=~/tmp/

" store the undo in undodir
"set undofile
"set undodir=~/.cache

" Strip trailing whitespace option
let stripTrailingWhitespace = 1


" TOhtml options
let html_number_lines = 1
let html_use_css = 1
let html_ignore_folding = 1
let html_use_encoding = "utf-8"

"Set the browser executable
let g:browser = 'xdg-open'
"}}}
"COMMON: specific vim behaviour {{{

"remove all trailing whitespace for specified files before write
autocmd BufWritePre * :call <SID>StripTrailingWhitespaces(0)

"set correct filetype for tmux
autocmd BufRead *.tmux.conf set filetype=tmux
autocmd BufRead *.mako set filetype=mako
autocmd BufRead *.ass, *asm set filetype=kickass

" make the current line highlighted only on current window
autocmd WinEnter * setlocal cursorline
autocmd WinLeave * setlocal nocursorline
" }}}
"TERMINAL: options for terminal emulators {{{
if $TERM == 'rxvt-unicode-256color' || $TERM == 'xterm'
    "Enable 256 colors support
    set t_Co=256
    "repair urxvt ctrl+pgup/down behaviour
    map [5^ <C-PageUp>
    map [6^ <C-PageDown>
elseif $TERM == 'screen' || $TERM == 'screen-256color'
    set term=screen-256color        "Set terminal type
    set t_Co=256                    "Enable 256 colors support
    set t_kN=[6;*~
    set t_kP=[5;*~
endif
if $TERM == 'linux' && !has("gui_running")
    "For term like linux terminal keep interface simple
    set nolist
    set nocursorline
    set nonumber
endif
"}}}
"PLUGINS: {{{
"KickAssembler {{{2
let g:kickass_path = '/home/gryf/c64/PCTools/Cross-assemblers/KickAssembler/KickAss.jar'
"}}}
" Calendar {{{2
let g:calendar_monday = 1
let g:calendar_weeknm = 1
"}}}
"CtrlP {{{2
let g:ctrlp_custom_ignore = {
    \ 'dir': '\.git$\|\.hg$\|\.svn$',
    \ 'file': '\.pyo$\|\.pyc$\|\.pyd$',
    \ }
let g:ctrlp_map = '<C-F>'
map <C-B> :CtrlPBuffer<CR>
"}}}
" DirDiff {{{2
let g:DirDiffExcludes = ".svn,CVS,*.class,*.exe,.*.swp,*.pyc,*.pyo"
" Make use of cursor keys
nmap <M-Up> [c
nmap <M-Down> ]c
nmap <C-Up> \dk
nmap <C-Down> \dj
" }}}
"Dragvisuals {{{2
vmap <expr> <C-LEFT> DVB_Drag('left')
vmap <expr> <C-RIGHT> DVB_Drag('right')
vmap <expr> <C-DOWN> DVB_Drag('down')
vmap <expr> <C-UP> DVB_Drag('up')
vmap <expr> D DVB_Duplicate()
"}}}
"Gundo {{{2
map <Leader>u :GundoToggle<cr>
"}}}
"Jedi {{{
" automatically popup is annoying
let g:jedi#popup_on_dot = 0
" also this one is pretty annoying
let g:jedi#show_call_signatures = "0"
"let g:languagetool_lang=pl
"}}}
"jsbeautify {{{2
nnoremap <silent> <leader>ff :call g:Jsbeautify()<cr>:retab!<cr>
"}}}
"LanguageTool {{{
let g:languagetool_jar='/opt/LanguageTool/languagetool-commandline.jar'
"let g:languagetool_lang=pl
"}}}
"mark {{{2
" addidtional colors --
fun! s:CustomHighlightings()
    highlight def MarkWord7 ctermbg=White ctermfg=Black guibg=#E8E8E8 guifg=Black
    highlight def MarkWord8 ctermbg=LightGray ctermfg=Black guibg=#C0C0C0 guifg=Black
    highlight def MarkWord9 ctermbg=DarkYellow ctermfg=Black guibg=#FFC299 guifg=Black
    highlight def MarkWord10 ctermbg=DarkGreen ctermfg=Black guibg=#6E9954 guifg=Black
endfun
autocmd ColorScheme * call <SID>CustomHighlightings()

"}}}
"NERDCommenter {{{2
let g:NERDSpaceDelims=1
"}}}
"NERDtree {{{
map <F2> :NERDTreeToggle<cr>
"}}}
" Occur {{{
nnoremap <silent> <unique> <Leader>oc :Occur<CR>
nnoremap <silent> <unique> <Leader>om :Moccur<CR>
nnoremap <silent> <unique> <Leader>8 *<C-o>:Moccur<CR>
" }}}
"Pydoc {{{2
let g:pydoc_cmd = "/usr/bin/pydoc"
"}}}
"Python indent{{{2
let g:python_version_2=1
"}}}
" Pythonhelper {{{2
let g:pythonhelper_updatetime = 1000
" }}}
"Riv {{{
" Don't fold the file; it's annoying
let g:riv_fold_level = -1
" formatting tables, doesn't work so good with complex grid tables
let g:riv_auto_format_table = 0
"}}}
"ShowMarks {{{2
let g:showmarks_ignore_type = "hqprm"
let g:showmarks_include = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
"}}}
"Tagbar {{{2
nmap <Leader>t :Tagbar<CR>
let g:tagbar_compact = 1
" Note: see statusline settings for status bar tag conf
"}}}
"VimWIKI {{{2
let g:vimwiki_list = [{'path': '~/vimwiki/',
          \ 'template_path': '~/vimwiki/',
          \ 'template_default': 'default',
          \ 'template_ext': '.tpl'}]
"redefine tab key for vimwiki
map <Leader>wn <Plug>VimwikiNextWord
map <Leader>wp <Plug>VimwikiPrevWord
" }}}
"}}}
"KEYS: User defined keyboard shortcuts {{{

"Cycle through buffers.
" map <C-p> :bp<CR>
" map <C-n> :bn<CR>

map <F5> :call <SID>Make()<cr>

map <F6> :echom <SID>CreateScratch()<CR>

"QuickFix jumps
map <F9> :cp<CR>
map <F10> :cn<CR>
map <F11> :lprevious<CR>
map <F12> :lnext<CR>
map <S-F9> :QFix<CR>
map <S-F11> :LWin<CR>

"remove trailing whitespaces
nnoremap <leader>e :StripTrailingWhitespaces!<CR>

" copy current buffer filename (full path)
nmap ,cn :silent call <SID>CopyFileName(1)<CR>
" copy current buffer filename (filename only)
nmap ,cs :silent call <SID>CopyFileName(0)<CR>

"open link under cursor in Firefox
map ]b :call OpenInWebBrowser()<cr>

"remove search highlight and refresh
nnoremap <silent> <C-l> :nohl<CR>:syn sync fromstart<CR><C-l>
map <F3> :call <SID>ChangeVCS()<cr>
map <F4> :call <SID>ToggleHex()<cr>
" }}}
" FUNCTIONS: usefull functions for all of th files {{{

" Switch VCSCommand current used VCS system
function <SID>ChangeVCS()
    echo ""
    let l:vcs = ["HG", "SVN", "CVS", "GIT"]
    let l:scv = {1: "HG", 2: "SVN", 3: "CVS", 4: "GIT"}
    let l:cho = ""
    let l:current = 0

    if exists("VCSCommandVCSTypeExplicitOverride") &&
        \ index(vcs, g:VCSCommandVCSTypeExplicitOverride) != -1
        let l:current = vcs[g:VCSCommandVCSTypeExplicitOverride]
    endif

    let l:choice = confirm('Switch VCS: ', "&" . join(l:vcs, "\n&"), l:current)
    execute ':redraw!'

    if has_key(l:scv, l:choice)
        let g:VCSCommandVCSTypeExplicitOverride=l:scv[l:choice]

        echohl Statement
        echo "Switched to " . g:VCSCommandVCSTypeExplicitOverride
        echohl None
    endif
endfunction

" Simple wrapper for :make command
function <SID>Make()
    echohl Statement
    echo "Running make (ctrl-c to cancel) ..."
    echohl Normal
    silent make
    if getqflist() != []
        copen
    endif
    redraw
endfunction

" Remove trailing whitespace
function <SID>StripTrailingWhitespaces(force)
    if a:force != 1 && g:stripTrailingWhitespace == 0
        return
    endif

    if a:force == 1 || &ft =~ 'python\|rst\|wiki\|javascript\|css\|html\|xml'
        " Preparation: save last search, and cursor position.
        let _s=@/
        let l = line(".")
        let c = col(".")
        " Do the business:
        %s/\s\+$//e
        " Clean up: restore previous search history, and cursor position
        let @/=_s
        call cursor(l, c)
    endif
endfunction
command -bang StripTrailingWhitespaces call <SID>StripTrailingWhitespaces(<bang>0)

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

" Toggle QuickFix buffer
command -bang -nargs=? QFix call QFixToggle(<bang>0)
function QFixToggle(forced)
  if exists("g:qfix_win") && a:forced == 0
    cclose
    unlet g:qfix_win
  else
    copen 10
    let g:qfix_win = bufnr("$")
  endif
endfunction

" Toggle location buffer
command -bang -nargs=? LWin call LocationWindowToggle(<bang>0)
function LocationWindowToggle(forced)
  if exists("g:loc_win") && a:forced == 0
    lclose
    unlet g:loc_win
  else
    lopen 10
    let g:loc_win = bufnr("$")
  endif
endfunction

" OpenInWebBrowser
" try to open url in selected web browser
function OpenInWebBrowser()
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
        call system(g:browser . " " . l:url)
        echohl Statement
        echo "Opened '" . l:url ."' in " . g:browser
    else
        echohl WarningMsg
        echo "Not an URL under cursor."
    endif
    echohl None
endfunction

" helper function to toggle hex mode
function <SID>ToggleHex()
    " hex mode should be considered a read-only operation
    " save values for modified and read-only for restoration later,
    " and clear the read-only flag for now
    let l:modified=&mod
    let l:oldreadonly=&readonly
    let &readonly=0
    let l:oldmodifiable=&modifiable
    let &modifiable=1
    if !exists("b:editHex") || !b:editHex
        " save old options
        let b:oldft=&ft
        let b:oldbin=&bin
        " set new options
        setlocal binary " make sure it overrides any textwidth, etc.
        let &ft="xxd"
        " set status
        let b:editHex=1
        " switch to hex editor
        %!xxd
    else
        " restore old options
        let &ft=b:oldft
        if !b:oldbin
            setlocal nobinary
        endif
        " set status
        let b:editHex=0
        " return to normal editing
        %!xxd -r
    endif
    " restore values for modified and read only state
    let &mod=l:modified
    let &readonly=l:oldreadonly
    let &modifiable=l:oldmodifiable
endfunction

function <SID>CreateScratch()
    new|setl bt=nofile bh=wipe nobl
    return ""
endfunction
"}}}
" GUI: detect graphics mode, set colorscheme {{{
if has('gui_running')
    " I like this font, but it looks like crap on linux
    "set guifont=Consolas\ 12
    " at least, some ttf font that looks good
    set guifont=DejaVuSansMonoForPowerline\ \Nerd\ Font\ 12
    " Unfortunately there is a problem with TTF fonts in my gvim instance.
    " After editing a while there are some leaving trash appearing on the
    " buffer. Refreshing the screen helps, but is kinda annoying. It is
    " probably my X11 setup, because on other similar workstations and setup I
    " didn't noticed such behavior. Fallback to fixed-misc for a while.
    "set guifont=Fixed\ 13
    set mouse=a                "Enable mouse support
    " No toolbar, menu, scrollbars, draw simple text tabs. This would keep
    " window in one place, and also this will conserve space. Tabs are huge
    " under GTK.
    set guioptions=agit
    "add menuitem OpenInWebBrowser
    nmenu 666 PopUp.&Open\ in\ browser :call OpenInWebBrowser()<cr>
    "Turn off annoying beep
    au GUIEnter * set vb t_vb=
endif
colorscheme wombat256grf
if $TERM == 'linux' && !has('gui_running')
    " fallback to basic 8-color colorscheme
    colorscheme pablo
endif
if has('win32')
    source $HOME/vimfiles/winrc.vim
endif
"}}}
" vim:ts=4:sw=4:wrap:fdm=marker:
