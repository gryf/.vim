# vim: set fileencoding=utf-8
import sys
import os
from datetime import datetime
from tempfile import mkstemp


LOGIN = "John"
PASS = "secret"
REST_ARTICLE = u""":Title: Title — This is a test
:Date: 2010-12-12T12:36:36+01:00
:Tags: this is a test, Blogger, rest

.. meta::
    :description: meta are completely ignored in blogger parsers

`Amet`, convallis sollicitudin, commodo a, purus. Nulla vitae eros a diam
blandit **mollis**. Proin luctus ``ls --color    ~/`` feugiat eros.

.. more

Pellentesque habitant morbi tristique senectus et *netus* et malesuada fames
ac turpis egestas. Duis ultricies urna: ``easy_install pygments``. Etiam enim
urna, pharetra suscipit, varius et, congue quis, odio. Donec `NES <Nintendo
Entertainment System>`:acronym: lobortis, elit bibendum euismod faucibus,
velit nibh egestas libero, vitae pellentesque elit augue ut massa.

test empty `acronym`:acronym: and `abbrev`:abbreviation:

Section 1
---------

Nulla consequat erat at massa. Vivamus id mi. Morbi purus enim, dapibus a,
facilisis non, tincidunt at, enim. Vestibulum ante ipsum primis in faucibus
orci luctus et ultrices posuere cubilia Curae; `WTF? <What the
fcuk?>`:abbreviation: Duis imperdiet eleifend arcu.  Cras magna ligula,
consequat at, tempor non, posuere.

Subsection 1.1
..............

.. sourcecode:: python

    import vim
    print vim.current.buffer.name

.. sourcecode:: unknown_lexer

    Cras dignissim vulputate metus.
    Phasellus eu quam. Quisque interdum cursus purus. In.

End.
"""


class Eval(object):
    """
    Communication class
    """
    value = ""
    blog = None
    gdata_delete = 0


class Dummy(sys.__class__):
    """
    Dummy class, for faking modules and other objects, not directly needed
    """
    def __getattr__(self, attrname):
        """ The dummy class should have no attribute """
        if attrname == 'util':
            return Dummy("util")
        return None

# fake vim module.
sys.modules["vim"] = Dummy("vim")


class MockBuffer(list):
    """
    Vim buffer-like class
    """
    def append(self, val, line=None):
        """
        Override append method to mimic vim.buffer append behaviour
        """
        if line is None:
            super(MockBuffer, self).append(val)
        else:
            super(MockBuffer, self).insert(line, val)


class Mock(object):
    """
    Generic all-purpose mock class
    """
    pass


import vim
vim.command = lambda x: None
vim.current = Mock()
vim.current.buffer = MockBuffer(REST_ARTICLE.split("\n"))
fdesc, vim.current.buffer.name = mkstemp()
vim.current.buffer.name += ".rst"
os.close(fdesc)  # close descriptor, only filename is needed


def mock_vim_eval(string):
    ints = ("g:blogger_draft", "g:blogger_maxarticles",
            "g:blogger_confirm_del")
    if string in ints:
        return "0"
    elif string == "g:blogger_stylesheets":
        return []
    else:
        return Eval.value
vim.eval = mock_vim_eval


class MockBlog(object):
    """
    Mock blog class
    """
    def __init__(self, name, id):
        self.name = name
        self.id = id

    def get_blog_name(self):
        return self.name

    def get_blog_id(self):
        return self.id

    def get_post_link(self):
        link = Mock()
        link.href = "http://www.mock.org"
        return link

    def get_post_id(self):
        return self.id


class MockPost(object):
    """
    Mock class imitating posts
    """
    def __init__(self):
        self.category = Mock()
        self.category = []
        self.id = None
        self.title = Mock()
        self.title.text = ""
        self.published = Mock()
        self.published.text = ""

    def add_label(self, label):
        item = Mock()
        item.term = label
        self.category.append(item)

    def get_post_id(self):
        return self.id


class MockBlogFeed(object):
    """
    Mock class for feed objects
    """
    def __init__(self, *args, **kwargs):
        self.entry = []
        if Eval.blog:
            for bid, bname in {1: 'one', 3: 'test', 7: 'blog_name'}.items():
                blog = MockBlog(bname, bid)
                self.entry.append(blog)


class MockPostFeed(object):
    """
    Mock class for feed objects
    """
    def __init__(self, *args, **kwargs):
        self.entry = []


from atom.data import Id, Updated
from gdata.blogger.client import BloggerClient

BloggerClient.get_blogs = lambda x: MockBlogFeed()

from gdata.client import BadAuthentication


def mock_client_login(self, login, password, source=None, service=None):
    """
    Mock method for client login.
    """
    if login != LOGIN or password != PASS:
        raise BadAuthentication("Incorrect username or password")
BloggerClient.client_login = mock_client_login


def mock_client_post(self, post, url=None):
    """
    Mimic post method
    """
    if Eval.value == 10:
        return None
    new_id = Id(text='1234567890')
    post.id = new_id
    date = datetime.utcnow()
    milli = str(date.microsecond)[:3]
    date = date.strftime("%Y-%m-%dT%H:%M:%S")
    date = date + ".%s+00:00" % milli
    post.updated = Updated(text=date)
    return post
BloggerClient.post = mock_client_post
BloggerClient.update = mock_client_post


def mock_client_delete(self, post):
    """
    Mock delete method
    """
    if not post:
        raise AttributeError("%s object has no attribute 'etag'" % type(post))
    if Eval.gdata_delete:
        return "404 Mock"
    return None
BloggerClient.delete = mock_client_delete


def mock_client_get_posts(self, blog_id):
    """
    Mock get_posts method
    """
    posts = (('title1', 1, "2000-01-01T00:04:00.001+01:00"),
             ('title2', 2, "2001-01-01T00:02:19.001+01:00"),
             ('title3', 3, "2002-01-01T00:01:00.001+01:00"),
             ('title4', 4, "2006-01-01T00:02:00.001+02:00"))
    feed = MockPostFeed()
    for p in posts:
        a = MockPost()
        a.id = p[1]
        a.title.text = p[0]
        a.published.text = p[2]
        feed.entry.append(a)
    return feed
BloggerClient.get_posts = mock_client_get_posts


def mock_client_get_feed(self, uri, desired_class=None):
    """
    Mock get_feed method
    """
    post = MockPost()
    post.add_label('test1')
    return post
BloggerClient.get_feed = mock_client_get_feed


from gdata.blogger.data import BlogPost


def mock_get_post_id(self):
    return self.id.text
BlogPost.get_post_id = mock_get_post_id
