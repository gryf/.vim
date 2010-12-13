"""
File: blogger.py
Author: Roman 'gryf' Dobosz
Description: This is blogger activity connected module. It is using gdata[1]
             blogger module to provide add/modify/delete articles interface.

             [1] http://code.google.com/p/gdata-python-client
"""

import datetime
import re

import atom
from gdata.blogger.client import BloggerClient, BLOG_POST_URL
from gdata.blogger.data import BlogPost


class VimBlogger(object):
    """
    Communicate with blogger through gdata.blogger modules
    """
    DATE_PATTERN = re.compile(r"^(\d{4}-\d{2}-\d{2})"
                              "T(\d{2}:\d{2}:\d{2})(\.\d{3})?[+-]"
                              "(\d{2}:\d{2})$")
    DATE_FORMAT = "%Y-%m-%d"
    TIME_FORMAT = "%H:%M:%S"
    TZ_FORMAT = "%H:%M"

    def __init__(self, blogname, login, password):
        """
        Initialization.
        """
        self.draft = True
        self.blog_id = None
        self.blog = None
        self.client = BloggerClient()
        self._authorize(login, password)

        self.feed = self.client.get_blogs()
        self._set_blog(blogname)

    def get_articles(self, maxarticles=0):
        """
        Return list of articles
        """
        feed = self.client.get_posts(self.blog_id)
        posts = []

        for index, entry in enumerate(feed.entry):
            if maxarticles and index >= maxarticles:
                break
            posts.append((entry.get_post_id(),
                          entry.title.text,
                          self._extract_date(entry.published.text)))
        return posts

    def create_article(self, html_doc, attrs=None):
        """
        Create new article
        html_doc is content of the article in HTML format, without headers,
        preamble, doctype and body tags.
        attrs is a dictionary that should hold title, date and tags.
        return BlogPost object
        """
        if not attrs:
            attrs = {}

        title = 'title' in attrs and attrs['title'] or ""
        title = atom.data.Title(text=title, type="text")
        html_doc = atom.data.Content(text=html_doc, type="html")

        new_post = BlogPost(title=title, content=html_doc)

        if 'tags' in attrs and attrs['tags']:
            for tag in attrs['tags'].split(','):
                new_post.add_label(tag.strip())

        if 'date' in attrs and attrs['date'] and \
                self._check_date(attrs['date']):
            new_post.published = atom.data.Published(text=attrs['date'])

        if self.draft:
            new_post.control = atom.data.Control(\
                  draft=atom.data.Draft(text='yes'))

        return self.client.post(new_post, BLOG_POST_URL % self.blog_id)

    def update_article(self, html_doc, attrs):
        """
        Update article.
        html_doc is content of the article in HTML format, without headers,
        preamble, doctype and body tags.
        attrs is a dictionary that should hold title, date and tags.
        return BlogPost object
        """
        if "id" not in attrs:
            raise Exception("Post Id not found in attributes!")

        post = self._get_post(attrs['id'])
        post.content = atom.data.Content(text=html_doc, type="html")

        # update published date
        if 'date' in attrs and attrs['date'] and \
                self._check_date(attrs['date']):
            post.published = atom.data.Published(text=attrs['date'])

        if 'title' in attrs and attrs['title']:
            post.title = atom.data.Title(text=attrs['title'], type="text")
        #
        # update tag list
        if 'tags' in attrs:
            tags = [tag.strip() for tag in attrs['tags'].split(',')]
            for index, label in enumerate(post.category):
                if label.term not in tags:
                    del(post.category[index])

            for tag in tags:
                self._add_tag(post, tag.strip())

        return self.client.update(post)

    def delete_article(self, post_id):
        """
        Delete selected article
        """
        if not post_id:
            return "No article id provided"

        post = self._get_post(post_id)
        self.client.delete(post)
        return None

    def _get_post(self, post_id):
        """
        Return post with specified ID
        """
        post_href = self.blog.get_post_link().href
        return self.client.get_feed(post_href + "/%s" % post_id,
                                    desired_class=BlogPost)

    def _add_tag(self, post, tag):
        """
        post - BlogPost object
        tag - string with tag/label to add
        """
        for label in post.category:
            if label.term == tag:
                return

        post.add_label(tag)

    def _extract_date(self, date_string, time=False):
        """
        Extract date from the string and optionally time
        """

        if not self.DATE_PATTERN.match(date_string):
            return False

        if not time:
            return self.DATE_PATTERN.match(date_string).groups()[0]

        groups = self.DATE_PATTERN.match(date_string).groups()
        return groups[0] + " " + groups[1]

    def _check_date(self, date):
        """
        Parse date as RFC 3339 format, for example:
            2010-11-30T21:06:48.678+01:00
            or
            2010-11-30T21:06:48+01:00

        Returns true, if date is acceptable, false otherwise
        """
        if not self.DATE_PATTERN.match(date):
            return False

        groups = self.DATE_PATTERN.match(date).groups()
        _date = groups[0]
        _time = groups[1]
        _tz = len(groups) == 3 and groups[2] or groups[3]

        try:
            datetime.datetime.strptime(_date, self.DATE_FORMAT)
            datetime.datetime.strptime(_time, self.TIME_FORMAT)
            datetime.datetime.strptime(_tz, self.TZ_FORMAT)
        except ValueError:
            return False

        return True

    def _authorize(self, login, password):
        """
        Try to authorize in Google service.
        Authorization is kept in client object. In case of wrong credentials,
        exception is thrown.
        """
        source = 'Vim rst2blogger interface'
        service = 'blogger'

        self.client.client_login(login,
                                 password,
                                 source=source,
                                 service=service)

    def _set_blog(self, blogname):
        """
        Set correct blog, as defined in blogname
        """
        for blog in self.feed.entry:
            if blog.get_blog_name() == blogname:
                self.blog_id = blog.get_blog_id()
                self.blog = blog
                break
