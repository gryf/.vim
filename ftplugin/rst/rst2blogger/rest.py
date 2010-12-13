"""
File: rest.py
Author: Roman 'gryf' Dobosz
Description: This module is responsible for conversion between reST and HTML
             with some goods added.
"""

import re

from docutils import core
from docutils import nodes
from docutils.parsers.rst import directives, Directive
from docutils.writers.html4css1 import Writer, HTMLTranslator

try:
    from pygments import highlight
    from pygments.lexers import get_lexer_by_name, TextLexer
    from pygments.formatters import HtmlFormatter

    class Pygments(Directive):
        """
        Source code syntax highlighting.
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
except ImportError:
    pass


class Attrs(object):
    ATTRS = {}


class CustomHTMLTranslator(HTMLTranslator):
    """
    Base class for reST files translations.
    There are couple of customizations for docinfo fields behaviour and
    abbreviations and acronyms.
    """
    def __init__(self, document):
        """
        Set some nice defaults for articles translations
        """
        HTMLTranslator.__init__(self, document)
        self.initial_header_level = 4

    def visit_section(self, node):
        """
        Don't affect document, just keep track of the section levels
        """
        self.section_level += 1

    def depart_section(self, node):
        self.section_level -= 1

    def visit_meta(self, node):
        pass

    def depart_meta(self, node):
        pass

    def visit_document(self, node):
        pass

    def depart_document(self, node):
        pass

    def depart_docinfo(self, node):
        """
        Reset body, remove unnecessary content.
        """
        self.body = []

    def visit_date(self, node):
        pass

    def depart_date(self, node):
        pass

    def visit_literal(self, node):
        """
        This is almos the same as the original one from HTMLTranslator class.
        The only difference is in used HTML tag: it uses 'code' instead of
        'tt'
        """
        self.body.append(self.starttag(node, 'code', ''))
        text = node.astext()
        for token in self.words_and_spaces.findall(text):
            if token.strip():
                # Protect text like "--an-option" and the regular expression
                # ``[+]?(\d+(\.\d*)?|\.\d+)`` from bad line wrapping
                if self.sollbruchstelle.search(token):
                    self.body.append('<span class="pre">%s</span>'
                                     % self.encode(token))
                else:
                    self.body.append(self.encode(token))
            elif token in ('\n', ' '):
                # Allow breaks at whitespace:
                self.body.append(token)
            else:
                # Protect runs of multiple spaces; the last space can wrap:
                self.body.append('&nbsp;' * (len(token) - 1) + ' ')
        self.body.append('</code>')
        # Content already processed:
        raise nodes.SkipNode

    def visit_acronym(self, node):
        """
        Define missing acronym HTML tag
        """
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
        """
        Define missing abbr HTML tag
        """
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


class NoHeaderHTMLTranslator(CustomHTMLTranslator):
    """
    Special subclass for generating only body of an article
    """
    def __init__(self, document):
        """
        Remove all needless parts of HTML document.
        """
        CustomHTMLTranslator.__init__(self, document)
        self.head = []
        self.meta = []
        self.head_prefix = ['', '', '', '', '']
        self.body_prefix = []
        self.body_suffix = []
        self.stylesheet = []
        self.generator = ('')

    def visit_field(self, node):
        """
        Harvest docinfo fields and store it in global dictionary.
        """
        key, val = [n.astext() for n in node]
        Attrs.ATTRS[key.lower()] = val.strip()

    def visit_date(self, node):
        """
        Store published date in global dictionary.
        """
        Attrs.ATTRS['date'] = node.astext()


class PreviewHTMLTranslator(CustomHTMLTranslator):
    """
    Class for display article in the browser as a preview.
    """
    CSS = []

    def __init__(self, document):
        """
        Alter levels for the heading tags, define custom, blog specific
        stylesheets. Note, that style_custom is present only locally to adjust
        way of display the page
        """
        CustomHTMLTranslator.__init__(self, document)
        self.initial_header_level = 1
        self.section_level = 1
        # order of css files is important
        self.default_stylesheets = PreviewHTMLTranslator.CSS
        self.stylesheet = [self.stylesheet_link % self.encode(css) \
                for css in self.default_stylesheets]
        self.body_ = []

    def depart_docinfo(self, node):
        """
        Overwrite body with some custom one. body_ will hold the first heading
        with title of the document.
        """
        self.body = self.body_

    def visit_field(self, node):
        """
        Make title visible as a heading
        """
        key, node_ = [n.astext() for n in node]
        key = key.lower()
        if key == 'title':
            self.head.append('<title>%s</title>\n' % self.encode(node_))
            self.body_.append('<h1 class="post-title entry-title">'
                             '<a href="#">%s</a></h1>\n' % self.encode(node_))


class BlogBodyWriter(Writer):
    """
    Custom Writer class for generating HTML partial with the article
    """
    def __init__(self):
        Writer.__init__(self)
        self.translator_class = NoHeaderHTMLTranslator

    def translate(self):
        self.document.settings.output_encoding = "utf-8"
        Writer.translate(self)


class BlogPreviewWriter(Writer):
    """
    Custom Writer class for generating full HTML of the article
    """
    def __init__(self, stylesheets=None):
        Writer.__init__(self)
        if not stylesheets:
            stylesheets = []
        self.translator_class = PreviewHTMLTranslator
        self.translator_class.CSS = stylesheets

    def translate(self):
        self.document.settings.output_encoding = "utf-8"
        Writer.translate(self)


def blogPreview(string, stylesheets=None):
    """
    Returns full HTML of the article.
    string argument is an article in reST
    """
    if not stylesheets:
        stylesheets = []
    html_output = core.publish_string(string,
                                      writer=BlogPreviewWriter(stylesheets))
    html_output = html_output.strip()
    html_output = html_output.replace("<!-- more -->", "\n<!-- more -->\n")
    return html_output


def blogArticleString(string):
    """
    Returns partial HTML of the article, and attribute dictionary
    string argument is an article in reST
    """
    # reset ATTRS
    Attrs.ATTRS = {}
    html_output = core.publish_string(string, writer=BlogBodyWriter())
    html_output = html_output.strip()
    html_output = html_output.replace("<!-- more -->", "\n<!-- more -->\n")
    attrs = {}
    for key in Attrs.ATTRS:
        if Attrs.ATTRS[key]:
            attrs[key] = Attrs.ATTRS[key]

    return html_output, attrs
