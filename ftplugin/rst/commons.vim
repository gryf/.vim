" Some common settings for all reSt files
setlocal textwidth=80
setlocal makeprg=rst2html.py\ %\ %.html
setlocal spell
setlocal smartindent
setlocal autoindent
setlocal formatoptions=tcq "set VIms default

map <F5> :call <SID>Rst2Blogger()<cr>

" Simple function, that translates reSt text into html with specified format, 
" suitable to copy and paste into blogger post.
fun <SID>Rst2Blogger()
python << EOF
import re

from docutils import core
from docutils import nodes
from docutils.writers.html4css1 import Writer, HTMLTranslator

import vim


class NoHeaderHTMLTranslator(HTMLTranslator):
    def __init__(self, document):
        HTMLTranslator.__init__(self,document)
        self.head_prefix = ['','','','','']
        self.body_prefix = []
        self.body_suffix = []
        self.stylesheet = []
        self.head = []
        self.meta = []
        self.generator = ('')
        self.initial_header_level = 2
        self.section_level = 2

    def visit_document(self, node):
        pass

    def depart_document(self, node):
        pass

    def visit_section(self, node):
        pass

    def depart_section(self, node):
        pass

    def visit_acronym(self, node):
        node_text = node.children[0].astext()
        node_text = node_text.replace('\n', ' ')
        patt = re.compile(r'^(.+)\s<(.+)>')

        if patt.match(node_text):
            node.children[0] = nodes.Text(patt.match(node_text).groups()[0])
            self.body.append(\
                self.starttag(node, 'acronym',
                              '', title=patt.match(node_text).groups()[1]))

        else:
            self.body.append(self.starttag(node, 'acronym', ''))


_w = Writer()
_w.translator_class = NoHeaderHTMLTranslator

def blogify(string):
    return core.publish_string(string, writer=_w)

bufcontent = "\n".join(vim.current.buffer)
name = vim.current.buffer.name
if name.lower().endswith(".rst"):
    name = name[:-4] + ".html"
    vim.command('new')

    vim.current.buffer[:] = blogify(bufcontent).split("\n")
    try:
        vim.command(r'silent! %s/<tt class="docutils literal">/<code>/g')
        vim.command(r'silent! %s/<\/tt>/<\/code>/g')
    except:
        pass
    try:
        vim.command(r'silent! %s/<!-- more -->/\r<!-- more -->\r\r/g')
    except:
        pass
    vim.command('w %s' % name)
    vim.command('bd')
else:
    print "Ihis is not reSt file. File should have '.rst' extension."

EOF
endfun

" This is similar to that above, but creates full html document
fun <SID>Restify()
python << EOF
from docutils import core
from docutils.writers.html4css1 import Writer, HTMLTranslator
import vim

_w = Writer()
_w.translator_class = HTMLTranslator

def reSTify(string):
    return core.publish_string(string,writer=_w)

bufcontent = "\n".join(vim.current.buffer)
name = vim.current.buffer.name
if name.lower().endswith(".rst"):
    name = name[:-4] + ".html"
    vim.command('new')

    vim.current.buffer[:] = reSTify(bufcontent).split("\n")
    vim.command(r'silent %s/<tt class="docutils literal">/<code>/g')
    vim.command(r'silent %s/<\/tt>/<\/code>/g')
    vim.command('w %s' % name)
    vim.command('bd')
else:
    print "It's not reSt file!"

EOF
endfun
