" Blogger vim interface.
" Provide some convinient functions for creating preview from the reST file 
" and to send articles to blog.

if exists("b:did_rst_plugin")
    finish " load only once
else
    let b:did_rst_plugin = 1
endif

if !exists("g:blogger_browser")
    let g:blogger_browser = 0
endif

if !exists("g:blogger_name")
    let g:blogger_name = ""
endif

if !exists("g:blogger_login")
    let g:blogger_login= ""
endif

if !exists("g:blogger_pass")
    let g:blogger_pass = ""
endif

map <F5> :call <SID>Restify()<cr>
map <F6> :call <SID>Rst2Blogger()<cr>

if !exists('*s:Restify')
    python << EOF
#{{{
import os
import sys
import webbrowser

import vim

scriptdir = os.path.dirname(vim.eval('expand("<sfile>")'))
sys.path.insert(0, scriptdir)
from bloggervim.rest import blogPreview, blogArticleString
from bloggervim.blogger import VimBlogger

#}}}
EOF

    " Translate reSt text into html fragment suitable for preview in browser. 
    fun <SID>Restify()
    python << EOF
# {{{
bufcontent = "\n".join(vim.current.buffer)
name = vim.current.buffer.name

name = name[:-4] + ".html"
html = blogPreview(bufcontent)
output_file = open(name, "w")
output_file.write(html)
output_file.close()
if vim.eval("g:blogger_browser"):
    webbrowser.open(name)
    print "Generated HTML has been opened in browser"
else:
    print "Generated HTML has been written to %s" % name
#}}}
EOF
    endfun

    " Generate headless html, gather title, dates and tags from filed list and 
    " then send it to blog.
    fun <SID>Rst2Blogger()
    python << EOF
#{{{
bufcontent = "\n".join(vim.current.buffer)
name = vim.current.buffer.name
html, attrs = blogArticleString(bufcontent)

login = vim.eval("g:blogger_login")
password = vim.eval("g:blogger_pass")
blogname = vim.eval("g:blogger_name")

if not password:
    password = vim.eval('inputsecret("Enter your gmail password: ")')

title = 'title' in attrs and attrs['title'] or None
date = 'date' in attrs and attrs['date'] or None
tags = 'tags' in attrs and attrs['tags'] or ""
tags = [tag.strip() for tag in tags.split(',')]
modified = 'modified' in attrs and attrs['modified'] or None

blog = VimBlogger(blogname, login, password)
print blog.create_article(title, html, tags=tags)

#}}}
EOF
    endfun
endif
