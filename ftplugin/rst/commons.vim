" Some common settings for all reSt files
set textwidth=80
set makeprg=rst2html.py\ %\ %.html
set spell
set smartindent
set autoindent
set formatoptions+=w

map <F5> :call Rst2Blogger()<cr>

" Simple function, that translates reSt text into html with specified format, 
" suitable to copy and paste into blogger post.
fun! Rst2Blogger()
python << EOF
from docutils import core
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

_w = Writer()
_w.translator_class = NoHeaderHTMLTranslator

def blogify(string):
    return core.publish_string(string,writer=_w)

bufcontent = "\n".join(vim.current.buffer)
name = vim.current.buffer.name
if name.lower().endswith(".rst"):
    name = name[:-4] + ".html"
    vim.command('new')

    vim.current.buffer[:] = blogify(bufcontent).split("\n")
    vim.command('saveas %s' % name)
    vim.command('bd')
else:
    print "This is not reSt file. File should have '.rst' extension."

EOF
endfun

" This is similar to that above, but creates full html document
fun! Restify()
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
    vim.command('saveas %s' % name)
    vim.command('bd')
else:
    print 'To nie jest plik reSt!'

EOF
endfun
