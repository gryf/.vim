if exists("b:did_pdpep8_functions")
    finish " only load once
else
    let b:did_pdpep8_functions = 1
endif

if !exists('*s:pdPep8')
  function s:pdPep8()
    set lazyredraw
    " Close any existing cwindows.
    cclose
    let l:grepformat_save = &grepformat
    let l:grepprogram_save = &grepprg
    set grepformat&vim
    set grepformat&vim
    let &grepformat = '%f:%l:%m'
    let &grepprg = 'c:\\Python27\\Scripts\\pep8.exe --repeat --ignore=E111'
    if &readonly == 0 | update | endif
    silent! grep! %
    let &grepformat = l:grepformat_save
    let &grepprg = l:grepprogram_save
    let l:mod_total = 0
    let l:win_count = 1
    " Determine correct window height
    windo let l:win_count = l:win_count + 1
    if l:win_count <= 2 | let l:win_count = 4 | endif
    windo let l:mod_total = l:mod_total + winheight(0)/l:win_count |
          \ execute 'resize +'.l:mod_total
    " Open cwindow
    execute 'belowright copen '.l:mod_total
    nnoremap <buffer> <silent> c :cclose<CR>
    set nolazyredraw
    redraw!
  endfunction
  command! Pep8 call s:pdPep8()
endif

if !exists('*s:pdPep8Buf')
  function s:pdPep8Buf()
      echohl Statement
      echo "Running pep8 (ctrl-c to cancel) ..."
      echohl Normal
      let file = expand('%:p')
      "let cmd = 'pylint --reports=n --output-format=text "' . file . '"'
      let cmd = 'c:\\Python26\\Scripts\\pep8.exe "' . file . '"'

      if has('win32') || has('win64')
          let cmd = 'cmd /c "' . cmd . '"'
      endif
      
      exec "bel silent new " . file . ".lint"
      exec "silent! read! " . cmd
  endfunction
  command! Pep8buf call s:pdPep8Buf()
endif
