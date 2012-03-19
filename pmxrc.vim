set fileencoding=utf-8
set runtimepath+=$VIM/vimfiles/bundle_pmx
set viewoptions=cursor
"set guifont=Consolas:h10:cEASTEUROPE
set guifont=DejaVu_Sans_Mono:h9:cEASTEUROPE
set shiftwidth=2
set softtabstop=2
set tabstop=2
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

"PMX: {{{
if exists("g:vim_bin_path")
  finish
endif
let g:vim_bin_path = expand($VIM) . '/bin'

let $REF_DRIVE='R:'
let $LOCAL_DRIVE='L:'
let $PMXOS='WINNT'
let $PDMODE='RELEASE'
let $SOLUTION='mes'
let $OUIDICTPATH='../genR.WIN'
let $PATH='c:\Python23;' . $PATH
let $USE_HG_REPO='Y'

if !exists("g:pmx_path")
  let g:pmx_path = "L:"
endif

if !has("python")
  finish
endif

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


" stupid hard-coded way to add paths to let VIm know where to look for the 
" files, yet it is not perfect.
python << EOF
import os
import vim

pmx_path = vim.eval("g:pmx_path")
pmx_path = pmx_path.replace("\\", "/")

if not pmx_path.endswith("/"):
  pmx_path += "/"

vim.command("set tags+=" + pmx_path + ".vim_cache/tags")

pyothers = ["runtime/System/BIN.Win/others/python/Lib/PIL",
            "runtime/System/BIN.Win/others/python/Lib/coverage",
            "runtime/System/BIN.Win/others/python/Lib/ctypes",
            "runtime/System/BIN.Win/others/python/Lib/pyPdf"]

pyfiles = ["runtime/System/pylib",
           "runtime/System/pylib/PythonWin",
           "runtime/System/pylib/pdgui",
           "runtime/System/pylib/pdoracle",
           "runtime/System/pylib/pdpersis",
           "runtime/System/pylib/pdunittest",
           "runtime/System/pylib/pdtest",
           "runtime/System/pylib/pdutil",
           "runtime/System/pylib/spyce",
           "runtime/System/pylib/std",
           "runtime/System/pylib/std/lib-old",
           "runtime/System/pylib/std/lib-tk",
           "runtime/System/pylib/win32/lib"]

for i in pyfiles:
  vim.command("set path+=" + pmx_path + i)

for i in pyothers:
  vim.command("set path+=" + pmx_path + i)

def map_drive_L(path):
  assert os.path.exists(path)
  path = os.path.abspath(path)
  if os.path.exists("L:"):
    os.system("subst L: /D")
  os.system("subst L: " + path)

def update_tags():
  assert os.path.exists(pmx_path)

  opl_cfg = os.path.normpath(os.path.join(vim.eval("$VIM"),
                                          "bin",
                                          "ctags_opl.cnf"))
  opl_path = os.path.normpath(os.path.join(pmx_path, "opl"))
  pylib_path = os.path.join(pmx_path, "runtime", "system", "pylib")
  pylib_path = os.path.normpath(pylib_path)
  pylib_path += " " + os.path.normpath(pmx_path + \
    'runtime/System/BIN.Win/others/python/Lib')

  tag_dir = os.path.join(pmx_path, ".vim_cache")
  tag_path = os.path.normpath(os.path.join(tag_dir, "tags"))

  if not os.path.exists(tag_dir):
    os.mkdir(tag_dir)

  # find tags for python files and tags for OPL files if exists
  ctags = os.path.join(vim.eval("$VIM"), "bin", "ctags.exe")
  ctags = os.path.normpath(ctags)
  cmd = 'start cmd /c '
  cmd += ctags + ' -R --python-kinds=-i'
  if os.path.exists(opl_path) and os.path.exists(opl_cfg):
    cmd += ' --options=' + opl_cfg
  cmd += ' -f ' + tag_path + ' ' + pylib_path
  if os.path.exists(opl_path) and os.path.exists(opl_cfg):
    cmd += ' ' + opl_path
  print cmd
  os.system(cmd)
EOF

command -nargs=1 -complete=dir MapDriveL py map_drive_L(<f-args>)
command UpdateTags py update_tags()
"}}}

" vim:ts=4:sw=4:wrap:fdm=marker:
