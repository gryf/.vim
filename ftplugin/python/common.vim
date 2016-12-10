setlocal cinkeys-=0#
setlocal indentkeys-=0#
setlocal foldlevel=100
setlocal foldmethod=indent
setlocal list
setlocal noautoindent
setlocal smartindent
setlocal cinwords=if,elif,else,for,while,try,except,finally,def,class,with
setlocal smarttab

setlocal statusline=%<%F                 " filename (fullpath)
setlocal statusline+=\ %h                " indicator for help buffer
setlocal statusline+=%m                  " modified flag
setlocal statusline+=%r                  " readonly flag
setlocal statusline+=\ %{TagInStatusLine()} " current tag and its type
setlocal statusline+=%=                  " switch to the right
setlocal statusline+=%(%l,%c%V%)         " line, column and virtual column
setlocal statusline+=\ %3p%%             " percentage of the file

set wildignore+=*.pyc

inoremap # X<BS>#

"set ofu=syntaxcomplete#Complete

"autocmd FileType python setlocal omnifunc=pysmell#Complete
let python_highlight_all=1

"I don't want to have pyflakes errors in qfix, it interfering with Pep8/Pylint
let g:pyflakes_use_quickfix = 0

"Load views for py files
autocmd BufWinLeave *.py mkview
autocmd BufWinEnter *.py silent loadview

"Something bad happens for python comments - it places 2 spaces instead of 1
"after the # sign. Workaround:
let g:NERDCustomDelimiters = {'python': {'left': '#'}}
let g:NERDSpaceDelims = 0
