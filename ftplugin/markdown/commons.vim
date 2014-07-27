" Some common settings for all reSt files
setlocal textwidth=80
setlocal makeprg=md2html.py\ \"%\"\ \"%:p:r.html\"
setlocal spell
setlocal smartindent
setlocal autoindent
setlocal formatoptions=tcq "set VIms default

autocmd BufWritePost *.md :silent make
