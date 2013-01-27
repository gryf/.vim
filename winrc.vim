set fileencoding=utf-8
set runtimepath+=$VIM/vimfiles/bundle_win
set viewoptions=cursor
"set guifont=Consolas:h10:cEASTEUROPE
set guifont=DejaVu_Sans_Mono:h9:cEASTEUROPE
set listchars=tab:>-,trail:.
set guioptions=ceg
set mouse=a
set enc=utf-8
set printoptions=number:y
set pfn=Consolas:h10:cEASTEUROPE

let Tlist_Ctags_Cmd = expand('$VIM/bin/ctags.exe')
let g:tagbar_ctags_bin =  expand('$VIM/bin/ctags.exe')
let g:browser = '"c:\Program Files\Mozilla Firefox\firefox.exe"'

autocmd BufWritePre *.spy :StripTrailingWhitespaces
autocmd BufWritePre *.spi :StripTrailingWhitespaces
autocmd BufWritePre *.opl :StripTrailingWhitespaces
autocmd BufRead *.opl set filetype=pd_opl
autocmd BufRead *.py set filetype=python

"CTRL-P
" Don't rely on VCS system, just do stuff relative to current dir. PMX sources 
" are too huge
let g:ctrlp_working_path_mode = 0

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

    " count number of open windows in the tab
    "let wincount = tabpagewinnr(v:lnum, '$')
    "if wincount > 1
    "    let label .= ', '.wincount
    "endif
    "let label .= '] '

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

" Switch between HG and CVS in vcscommand plugin
function <SID>VCSSwitch()
    echohl Statement
    if exists("g:VCSTypeOverride")
        if g:VCSTypeOverride == "HG"
            let g:VCSTypeOverride = "CVS"
            echo "Switched to CVS"
        else
            let g:VCSTypeOverride = "HG"
            echo "Switched to HG"
        endif
    else
        let g:VCSTypeOverride = "HG"
        echo "Switched to HG"
    endif
    echohl Normal
endfunction
map <F3> :call <SID>VCSSwitch()<cr>

" vim:ts=4:sw=4:wrap:fdm=marker:
