" reST to blogger vim interface.
" Provide some convinient commands for creating preview from the reST file 
" and to send articles to blog.

if exists("b:did_rst_plugin")
    finish " load only once
else
    let b:did_blogger_plugin = 1
endif

if exists(':PreviewBlogArticle')
    finish
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

if !exists("g:blogger_draft")
    let g:blogger_draft = 1
endif

if !exists("g:blogger_maxarticles")
    let g:blogger_maxarticles = 0
endif

if !exists("g:blogger_confirm_del")
    let g:blogger_confirm_del = 1
endif

if !exists("g:blogger_stylesheets")
    let g:blogger_stylesheets = []
endif

python << EOF
import os
import sys

import vim

scriptdir = os.path.dirname(vim.eval('expand("<sfile>")'))
sys.path.insert(0, scriptdir)

try:
    from rst2blogger.main import Rst2Blogger
except ImportError:
    print "Plugin vimblogger cannot be loaded, due to lack of required modules"
EOF

if !exists(":PreviewBlogArticle")
    command PreviewBlogArticle py print Rst2Blogger().preview()
endif

if !exists(":SendBlogArticle")
    command SendBlogArticle py print Rst2Blogger().post()
endif

if !exists(":DeleteBlogArticle")
    command DeleteBlogArticle py print Rst2Blogger().delete()
endif
