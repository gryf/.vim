" Some common settings for all reSt files
setlocal textwidth=80
setlocal makeprg=rst2html.py\ \"%\"\ \"%:p:r.html\"
setlocal spell
setlocal smartindent
setlocal autoindent
setlocal formatoptions=tcq "set VIms default

let g:blogger_login="gryf73"
let g:blogger_name="rdobosz"
let g:blogger_browser=1
let g:blogger_stylesheets=["css/widget_css_2_bundle.css", "css/style_custom.css", "css/style_blogger.css"]

map <F6> :PreviewBlogArticle<cr>
map <F7> :SendBlogArticle<cr>
