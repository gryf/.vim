" Some common settings for all reSt files
setlocal textwidth=80
setlocal makeprg=rst2html.py\ %\ %.html
setlocal spell
setlocal smartindent
setlocal autoindent
setlocal formatoptions=tcq "set VIms default

if exists("b:did_rst_plugin")
    finish " only load once
else
    let b:did_rst_plugin = 1
endif

map <F5> :call <SID>Rst2Blogger()<cr>

if !exists('*s:Rst2Blogger')
    " Simple function, that translates reSt text into html with specified format, 
    " suitable to copy and paste into blogger post.
    fun <SID>Rst2Blogger()
    python << EOF
import re

from docutils import core
from docutils import nodes
from docutils.parsers.rst import directives, Directive
from docutils.writers.html4css1 import Writer, HTMLTranslator

from pygments import highlight
from pygments.lexers import get_lexer_by_name, TextLexer
from pygments.formatters import HtmlFormatter

import vim

class Pygments(Directive):
    """
    Source code syntax hightlighting.
    """
    required_arguments = 1
    optional_arguments = 0
    final_argument_whitespace = True
    has_content = True

    def run(self):
        self.assert_has_content()
        try:
            lexer = get_lexer_by_name(self.arguments[0])
        except ValueError:
            # no lexer found - use the text one instead of an exception
            lexer = TextLexer()
        # take an arbitrary option if more than one is given
        formatter = HtmlFormatter(noclasses=True)
        parsed = highlight(u'\n'.join(self.content), lexer, formatter)
        return [nodes.raw('', parsed, format='html')]

directives.register_directive('sourcecode', Pygments)

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

    def visit_abbreviation(self, node):
        node_text = node.children[0].astext()
        node_text = node_text.replace('\n', ' ')
        patt = re.compile(r'^(.+)\s<(.+)>')

        if patt.match(node_text):
            node.children[0] = nodes.Text(patt.match(node_text).groups()[0])
            self.body.append(\
                self.starttag(node, 'abbr',
                              '', title=patt.match(node_text).groups()[1]))

        else:
            self.body.append(self.starttag(node, 'abbr', ''))


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
        vim.command(r'silent! %s/<!-- more -->/\r<!-- more -->\r/g')
    except:
        pass
    vim.command('w %s' % name.replace(' ', '\ '))
    vim.command('bd')
else:
    print "Ihis is not reSt file. File should have '.rst' extension."

EOF
    endfun
endif

if !exists('*s:Restify')
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
endif
