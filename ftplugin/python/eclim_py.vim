" ftplugin for python.
" See: eclim_py plugin in plugins dir
" Global Variables {{{

if !exists("g:EclimPythonValidate")
  let g:EclimPythonValidate = 1
endif

" }}}

" Autocmds {{{

if g:EclimPythonValidate
  augroup eclim_python_validate
    autocmd! BufWritePost <buffer>
    autocmd BufWritePost <buffer> call Validate(1)
  augroup END
endif

" }}}

if !exists(":Validate")
  command -nargs=0 -buffer Validate :call Validate(0)
endif
if !exists(":PyLint")
  command -nargs=0 -buffer PyLint :call PyLint()
endif

