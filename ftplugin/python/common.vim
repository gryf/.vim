setlocal cinkeys-=0#
setlocal indentkeys-=0#
setlocal expandtab
setlocal foldlevel=100
setlocal foldmethod=indent
setlocal list
setlocal noautoindent
setlocal shiftwidth=4
setlocal smartindent
setlocal cinwords=if,elif,else,for,while,try,except,finally,def,class,with
setlocal smarttab
setlocal softtabstop=4
setlocal tabstop=4
setlocal textwidth=78
setlocal colorcolumn=+1

set wildignore+=*.pyc

"inoremap # X<BS>#

"set ofu=syntaxcomplete#Complete

"autocmd FileType python setlocal omnifunc=pysmell#Complete
let python_highlight_all=1

"Load views for py files
autocmd BufWinLeave *.py mkview
autocmd BufWinEnter *.py silent loadview

compiler pylint

finish "end here. all below is just for the record.

" Pylint function, which can be optionally mapped to some keys. Currently 
" not used.
if !exists('*<SID>runPyLint')
    function <SID>runPyLint()
        echohl Statement
        echo "Running pylint (ctrl-c to cancel) ..."
        echohl Normal
        :Pylint
    endfunction
endif

if !exists('*<SID>PyLintBuf')
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
endif

