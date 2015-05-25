" Some common settings for all reSt files
setlocal textwidth=80
setlocal makeprg=rst2html.py\ \"%\"\ \"%:p:r.html\"
setlocal spell
setlocal smartindent
setlocal autoindent
setlocal formatoptions=tcq  "set VIms default

function <SID>ShowInBrowser()
    let l:uri = expand("%:p:r") . ".html"
    silent make
    call system(g:browser . " " . l:uri)

    echohl Statement
    echo "Opened '" . l:uri ."' in " . g:browser
    echohl None
endfunction

if !exists(":ShowInBrowser")
    command ShowInBrowser call s:ShowInBrowser()
    map <S-F5> :ShowInBrowser<CR>
endif
