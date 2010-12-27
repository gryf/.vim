# vim: fileencoding=utf8
"""
File: main.py
Author: Roman 'gryf' Dobosz
Description: main file to provide fuctionality between vim and moudles rest
             and blogger
"""

import webbrowser
from xml.dom import minidom
from xml.parsers.expat import ExpatError

import vim

from rst2blogger.rest import blogPreview, blogArticleString
try:
    from rst2blogger.rest import register
except ImportError:
    pass

from rst2blogger.blogger import VimBlogger


class Rst2Blogger(object):
    """
    Provide convenient way to communicate between vim and blogger through reST
    """
    def __init__(self):
        vim.command('call setqflist([])')

        self.buff = vim.current.buffer
        self.docinfo_len = 0
        self._set_docinfo_len()
        self.login = vim.eval("g:blogger_login")
        self.password = vim.eval("g:blogger_pass")
        self.blogname = vim.eval("g:blogger_name")
        self.buffer_encoding = vim.eval("&fileencoding")
        self.vim_encoding = vim.eval("&encoding")
        self.draft = int(vim.eval("g:blogger_draft"))
        self.maxarticles = int(vim.eval("g:blogger_maxarticles"))
        self.confirm_del = int(vim.eval("g:blogger_confirm_del"))
        self.stylesheets = vim.eval("g:blogger_stylesheets")
        self.pygments_class = vim.eval("g:blogger_pygments_class")
        try:
            register(self.pygments_class)
        except NameError:
            pass

    def preview(self):
        """
        Generate HTML Blogger article preview and (optionally) display it in
        systems' web browser
        """
        bufcontent = "\n".join(self.buff)
        name = self.buff.name

        name = name[:-4] + ".html"
        html = blogPreview(bufcontent, self.stylesheets)
        self._open_qf(self._check_html(html))

        output_file = open(name, "w")
        output_file.write(html)
        output_file.close()
        if vim.eval("g:blogger_browser"):
            webbrowser.open(name)
            return "Generated HTML has been opened in browser"
        else:
            return "Generated HTML has been written to %s" % name

    def post(self):
        """
        Do post article
        """
        bufcontent = "\n".join(self.buff)
        html, attrs = blogArticleString(bufcontent)

        parse_msg = self._check_html(html, True)
        if parse_msg:
            self._open_qf(parse_msg)
            return "There are errors in generated document"

        if not self.password:
            self.password = \
                    vim.eval('inputsecret("Enter your gmail password: ")')

        blog = VimBlogger(self.blogname, self.login, self.password)
        blog.draft = self.draft > 0

        if 'id' in attrs and attrs['id']:
            post = blog.update_article(html, attrs=attrs)
            msg = unicode("Article '%s' has been updated" % post.title.text)
            msg = msg.encode(self.vim_encoding)
        else:
            post = blog.create_article(html, attrs=attrs)
            msg = "New article with id %s has been created" % \
                    post.get_post_id()

        for item, value in (('id', post.get_post_id()),
                            ('date', post.published.text),
                            ('title', post.title.text),
                            ('modified', post.updated.text),
                            ('tags',
                             ", ".join([cat.term for cat in post.category]))):
            self._update_docinfo(item, value)
        return msg

    def delete(self):
        """
        Get list of articles, display it to the user, make him choose one and
        delete
        """
        if not self.password:
            self.password = \
                    vim.eval('inputsecret("Enter your gmail password: ")')
        blog = VimBlogger(self.blogname, self.login, self.password)

        posts = blog.get_articles(self.maxarticles)

        msg = u"inputlist(["
        for index, entries in enumerate(posts):
            line = "%2d %s  %s" % (index + 1,
                                   entries[1],
                                   entries[2])
            msg += u'"' + line.replace('"', '\\"') + u'",'
        msg = msg[:-1]
        msg += u"])"
        msg = unicode(msg).encode(self.vim_encoding)

        choice = int(vim.eval(msg))
        if choice:
            art = posts[choice - 1]
            msg = 'confirm("You are about to delete article \'%s\'. '
            msg += 'Are you sure?"'
            msg = unicode(msg % art[1]).encode(self.vim_encoding)
            msg += ', "&No\n&Yes")'

            if self.confirm_del:
                choice = int(vim.eval(msg))
            else:
                choice = 2

            if choice == 2:
                blog.delete_article(art[0])
                return "Article deleted"
        return "No articles deleted"

    def _update_docinfo(self, attr, val):
        """
        Update current buffer with attributes value
        """

        val = unicode(":%s: %s" % (attr.capitalize(), val))
        val = val.encode(self.buffer_encoding)

        if not self.docinfo_len:
            self.buff.append(val, 0)
            return

        for num, line in enumerate(self.buff[:self.docinfo_len]):
            if ':%s:' % attr in line.lower() and line.startswith(":"):
                self.buff[num] = val
                return

        self.buff.append(val, 0)
        self.docinfo_len += 1

    def _set_docinfo_len(self):
        """
        Set docinfo_len, which means number of lines from the beginning of the
        buffer to the first empty line.
        """
        for num, line in enumerate(self.buff):
            if line and line.startswith(':'):
                continue
            elif not line:
                self.docinfo_len = num
                break
            else:
                self.docinfo_len = 0
                break

    def _open_qf(self, msg):
        """
        Open VIm QuickFix window with message, if argument msg is non empty
        string.
        """
        if msg:
            msg1 = "There are problems reported by XML parser:"
            msg2 = "Check generated html for errors."
            vim.command('call setqflist([{"text": "%s"}, {"text": "%s"}, '
                        '{"text": "%s"}])' % (msg1, msg, msg2))
            vim.command('copen')

    def _check_html(self, html, add_container=False):
        """
        Check HTML generated document, by simply use minidom parser
        If add_container is set to True, entire document is wrapped inside
        additional div
        returns empty string if parses succeed, else exception message.
        """

        # minidom doesn't understand html entities like '&nbsp;' For checking
        # purpose it is perfectly ok, to switch them with '&amp;'
        html = html.replace("&nbsp;", "&amp;")
        if add_container:
            html = "<div>" + html + "</div>"

        message = ""
        try:
            minidom.parseString(html)
        except ExpatError as ex:
            message = str(ex)

        return message
