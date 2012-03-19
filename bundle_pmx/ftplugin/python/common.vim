setlocal cinkeys-=0#
setlocal indentkeys-=0#
setlocal expandtab
setlocal foldlevel=100
setlocal foldmethod=indent
setlocal list
setlocal noautoindent
setlocal smartindent
setlocal cinwords=if,elif,else,for,while,try,except,finally,def,class,with
setlocal smarttab
setlocal textwidth=78
setlocal colorcolumn=+1
" overwrite status line
setlocal statusline=%<%F\ %{TagInStatusLine()}\ %h%m%r%=%(%l,%c%V%)\ %3p%%

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

compiler autopylint

if !exists('*<SID>PyLintBuf')
    function <SID>PyLintBuf(save_and_close)
        echohl Statement
        echo "Running pylint (ctrl-c to cancel) ..."
        echohl Normal
        let filename = expand('%:p')
        let cmd = expand('$VIM') . '\bin\autopylint.py -8 "' . filename . '"'

        if has('win32') || has('win64')
            let cmd = 'cmd /c ' . cmd
        endif

        exec "bel silent new " . filename . ".lint"
        exec "silent! read! " . cmd
        if a:save_and_close != 0
          exec "w!"
          exec "bd"
        endif
    endfunction
    command -bang -nargs=? PyLintBuf call <SID>PyLintBuf(<bang>0)
endif
map <F6> :PyLintBuf<cr>

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

