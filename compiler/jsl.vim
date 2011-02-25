" Vim compiler file
" Compiler: pdf creator out of LaTeX files using rubber
if exists("current_compiler")
    finish
endif

let current_compiler = "jsl"
if exists(":CompilerSet") != 2 " older Vim always used :setlocal
    command -nargs=* CompilerSet setlocal <args>
endif

CompilerSet makeprg=jsl\ -nologo\ -nofilelisting\ -nosummary\ -nocontext\ -process\ %
CompilerSet errorformat=%f(%l):\ %m

