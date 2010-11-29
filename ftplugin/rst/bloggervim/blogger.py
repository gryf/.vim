# vim: fileencoding=utf8
#
# Blogger interface to make easy way to create/update articles for specified
# blog.
#
# It is assumed one way communication only, so you may create or update an
# article from reST source files. There is no way to recreate article from
# html to reST format.
#
# requirements:
#
# - Vim compiled with +python
# - python 2.x (tested with 2.6)
# - modules
#   - gdata (http://code.google.com/p/gdata-python-client)
#   - docutils (http://docutils.sourceforge.net)
#   - pytz (http://pytz.sourceforge.net)
#
# USE CASES:
# 1. Create new post
#
# use reST template:
#                       ===8<---
# :Title: Blog post title
# :Date: optional publish date (for example: 2010-11-28 18:47:05),
#        default: now()
# :Modified: optional, default: None
# :Tags: comma separated blog tags
#
# .. more
#
#                       --->8===
#
# All four docinfo are optional, however it is nice to give at least a title
# to the article :)
#
#
#
# which is provided under templates directory or as a
# snipMate shoortcut (see .vim/snippets/rst.snippets)
#

# vim.eval('inputsecret("Password: ")')
# echomsg expand("%:p")
#-----------------------------------------------------------------------------
#
import getpass  # TODO: remove
import time
import datetime

import pytz
import atom
from gdata.blogger.client import BloggerClient


class VimBlogger(object):
    """
    """

    def __init__(self, blogname, login, password):
        """
        """
        self.blog = None
        self.client = BloggerClient()
        self._authorize(login, password)

        self.feed = self.client.get_blogs()
        self._set_blog(blogname)
        #self._get_arts(blogname)

    def _set_blog(self, blogname):
        """
        """
        for blog in self.feed.entry:
            if blog.get_blog_name() == blogname:
                self.blog = blog
                break


    def _get_arts(self, blogname):
        """
        """
        feed = self.client.get_posts(self.blog.get_blog_id())
        for entry in feed.entry:
            print entry.title.text
        #
        import ipdb; ipdb.set_trace()
        #
        # entry.content obiekt zawiera ciało artykułu (entry.content.text
        # posiada czystą formę która mnie interesuje najbardziej, do której
        # można pisać
        #
        # entry.category - lista wszystkich kategorii (blogowych tagów), które
        # post posiada. Są to elementy klasy atom.data.Category, które
        # łatwiutko stworzyć i dodać do posta:
        # import atom
        # cat1 = atom.data.Category()
        # cat1.term = "nowy tag dla bloggera"
        # entry.category.append(cat1)
        #
        # entry.title przechowuje tytuł posta

    def _authorize(self, login, password):
        """
        """
        source = 'Blogger_Python_Sample-2.0'
        service = 'blogger'

        self.client.client_login(login,
                                 password,
                                 source=source,
                                 service=service)
    def create_article(self, title, html_doc, tags=None):
        """
        """

        blog_id = self.blog.get_blog_id()
        if tags is None:
            tags = []
        return self.client.add_post(blog_id, title, html_doc, labels=tags,
                                    draft=True)

    def update_article(self, title, html_doc, tags=None):
        """
        """
        pass

if __name__ == "__main__":
    p = getpass.getpass("Password: ")
    b = VimBlogger("rdobosz", "gryf73@gmail.com", p)
