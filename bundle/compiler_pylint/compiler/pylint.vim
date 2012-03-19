" Vim compiler file for Python
" Compiler:     Static code checking tool for Python
" Maintainer:   Roman 'gryf' Dobosz
" Last Change:  2010-09-12
" Version:      1.0 
if exists("current_compiler")
    finish
endif

let current_compiler = "pylint"
CompilerSet makeprg=pylint_parseable.py\ %
CompilerSet efm=%f:\ %t:\ %l:\ %c:\ %m,%f:\ %t:\ %l:\ %m
