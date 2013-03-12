set fileencoding=utf-8
set guifont=DejaVu_Sans_Mono:h9:cEASTEUROPE
set listchars=tab:>-,trail:.
set guioptions=ceg
set enc=utf-8

" assuming all useful tools are in $VIM/bin directory
let $PATH .= ";".expand('$VIM/bin')
let g:browser = '"c:\Program Files\Mozilla Firefox\firefox.exe"'

autocmd BufWritePre *.spy :StripTrailingWhitespaces
autocmd BufWritePre *.spi :StripTrailingWhitespaces
autocmd BufWritePre *.opl :StripTrailingWhitespaces
autocmd BufRead *.opl set filetype=pd_opl
autocmd BufRead *.py set filetype=python

"Grep 
" Note: xargs from GnuWin32 package are unusable with this plugin - it refuses
"       to pass find output to the grep. Fortunately, cygwin version (which is
"       newer in fact) is working just fine. The only thing that is needed to
"       set is to quote arguments passed to find:
let Grep_Shell_Quote_Char='"'
" If for some reason it is needed to use tools from GnuWin32 project, comment 
" out following line:
let Grep_Cygwin_Find=1
" and uncomment one below:
"let Grep_Find_Use_Xargs=0 
" Note: without xargs processing of the output will be much more slower than 
"       with it.

if has("gui_running")
    highlight SpellBad term=underline gui=undercurl guisp=Orange
endif

"maximize window
au GUIEnter * simalt ~x

function GuiTabLabel()
    " add the tab number
    let label = '' "'['.tabpagenr()

    let buflist = tabpagebuflist(v:lnum)

    " add the file name without path information
    let n = bufname(buflist[tabpagewinnr(v:lnum) - 1])
    let label .= fnamemodify(n, ':t')

    " modified since the last save?
    for bufnr in buflist
        if getbufvar(bufnr, '&modified')
            let label .= ' *'
            break
        endif
    endfor

    return label
endfunction
set guitablabel=%{GuiTabLabel()}

if exists("g:vim_bin_path")
  finish
endif
let g:vim_bin_path = expand($VIM) . '/bin'

" vim:ts=4:sw=4:wrap:fdm=marker:
