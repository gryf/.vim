set cinkeys-=0#
set expandtab
set foldlevel=100
set foldmethod=indent
set indentkeys-=0#
set list
set noautoindent
set shiftwidth=4
set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class,with
set smarttab
set softtabstop=4
set tabstop=4
set textwidth=78
set colorcolumn=+1

inoremap # X<BS>#

"set ofu=syntaxcomplete#Complete

let g:pylint_onwrite = 0 " I don't want to run pylint on every save
compiler pylint

"autocmd FileType python setlocal omnifunc=pysmell#Complete
let python_highlight_all=1

"Load views for py files
autocmd BufWinLeave *.py mkview
autocmd BufWinEnter *.py silent loadview
