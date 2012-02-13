import os
import sys
import unittest

this_dir = os.path.dirname(os.path.abspath(__file__))
this_dir = os.path.abspath(os.path.join(this_dir, "../.."))
sys.path.insert(0, this_dir)

from rst2blogger.tests import shared
from rst2blogger.blogger import VimBlogger


class TestCheckDates(unittest.TestCase):
    """
    Tests for method VimBlogger._check_date
    """
    def setUp(self):
        """
        Create VimBlogger object
        """
        self.vimb = VimBlogger(None, shared.LOGIN, shared.PASS)

    def test_happy_case_CET(self):
        """
        Test on good date string on Central and East Europe
        """
        date = "2000-01-01T00:00:00.001+01:00"
        self.assertTrue(self.vimb._check_date(date))

    def test_happy_case_HST(self):
        """
        Test on good date string on Hawaii Time Zone
        """
        date = "2000-01-01T00:00:00.001-10:00"
        self.assertTrue(self.vimb._check_date(date))

    def test_happy_case_GMT(self):
        """
        Test UTC date string
        """
        date = "2000-01-01T00:00:00.001-00:00"
        self.assertTrue(self.vimb._check_date(date))

    def test_without_milliseconds(self):
        """
        Test on date string without milliseconds
        """
        date = "2000-01-01T00:00:00+01:00"
        self.assertTrue(self.vimb._check_date(date))

    def test_wrong_tz_format(self):
        """
        Test date with wrong timezone format (hour have no leading 0)
        """
        date = "2000-01-01T00:00:00.001+1:00"
        self.assertFalse(self.vimb._check_date(date))

        # Test date with wrong timezone format (minute have only one digit)
        date = "2000-01-01T00:00:00.001+01:0"
        self.assertFalse(self.vimb._check_date(date))

        # Test date with wrong timezone format (hours and minutes hasn't been
        # separated by colon)
        date = "2000-01-01T00:00:00.001+0100"
        self.assertFalse(self.vimb._check_date(date))

    def test_wrong_milliseconds(self):
        """
        Test date with wrong format of milliseconds (.01 instead of .010)
        """
        date = "2000-01-01T00:00:00.01+01:00"
        self.assertFalse(self.vimb._check_date(date))

        # Test date with wrong format of milliseconds (.1 instead of .100)
        date = "2000-01-01T00:00:00.1+01:00"
        self.assertFalse(self.vimb._check_date(date))

        # Test date with spolied format (dot for milliseconds, but no digits)
        date = "2000-01-01T00:00:00.+01:00"
        self.assertFalse(self.vimb._check_date(date))

    def test_good_milliseconds(self):
        """
        Test date with correct format of milliseconds
        """
        date = "2000-01-01T00:00:00.000+01:00"
        self.assertTrue(self.vimb._check_date(date), date + " is incorrect")

        date = "2000-01-01T00:00:00.999+01:00"
        self.assertTrue(self.vimb._check_date(date), date + " is incorrect")

    def test_wrong_hours(self):
        """
        Test date with wrong hours value
        """
        date = "2000-01-01T24:00:00.001+01:00"
        self.assertFalse(self.vimb._check_date(date))

    def test_good_hours(self):
        """
        Test date with correct hours values
        """
        date = "2000-01-01T00:00:00.001+01:00"
        self.assertTrue(self.vimb._check_date(date), date + " is incorrect")
        date = "2000-01-01T23:00:00.001+01:00"
        self.assertTrue(self.vimb._check_date(date), date + " is incorrect")

    def test_wrong_minutes(self):
        """
        Test date with wrong minutes value
        """
        date = "2000-01-01T00:60:00.001+01:00"
        self.assertFalse(self.vimb._check_date(date))

        date = "2000-01-01T00:000:00.001+01:00"
        self.assertFalse(self.vimb._check_date(date))

        date = "2000-01-01T00:1:00.001+01:00"
        self.assertFalse(self.vimb._check_date(date))

    def test_good_minutes(self):
        """
        Test date with correct minutes values
        """
        date = "2000-01-01T00:01:00.001+01:00"
        self.assertTrue(self.vimb._check_date(date))

        date = "2000-01-01T00:59:00.001+01:00"
        self.assertTrue(self.vimb._check_date(date))

    def test_wrong_seconds(self):
        """
        Test date with wrong seconds value
        """
        date = "2000-01-01T00:00:60.001+01:00"
        self.assertFalse(self.vimb._check_date(date))

    def test_good_seconds(self):
        """
        Test date with good seconds values
        """
        for second in range(60):
            date = "2000-01-01T00:00:%0.2d.001+01:00" % second
            self.assertTrue(self.vimb._check_date(date))

    def test_wrong_days(self):
        """
        Test date with incorrect days (january has always 31 days, no month
        has lower number than 1)
        """
        date = "2000-01-32T00:00:00.001+01:00"
        self.assertFalse(self.vimb._check_date(date))

        date = "2000-01-00T00:00:00.001+01:00"
        self.assertFalse(self.vimb._check_date(date))

    def test_good_days(self):
        """
        Test date with correct days (january has always 31 days)
        """
        date = "2000-01-01T00:00:00.001+01:00"
        self.assertTrue(self.vimb._check_date(date))

        date = "2000-01-31T00:00:00.001+01:00"
        self.assertTrue(self.vimb._check_date(date))

    def test_wrong_month(self):
        """
        Test date with wrong month
        """
        date = "2000-00-01T00:00:00.001+01:00"
        self.assertFalse(self.vimb._check_date(date))

        date = "2000-13-01T00:00:00.001+01:00"
        self.assertFalse(self.vimb._check_date(date))

        date = "2000-1-01T00:00:00.001+01:00"
        self.assertFalse(self.vimb._check_date(date))

        date = "2000-001-01T00:00:00.001+01:00"
        self.assertFalse(self.vimb._check_date(date))

    def test_good_month(self):
        """
        Test date with correct months
        """
        date = "2000-01-01T00:00:00.001+01:00"
        self.assertTrue(self.vimb._check_date(date))

        date = "2000-12-01T00:00:00.001+01:00"
        self.assertTrue(self.vimb._check_date(date))

    def test_wrong_year(self):
        """
        Test date with wrong year
        """
        date = "0000-01-01T00:00:00.001+01:00"
        self.assertFalse(self.vimb._check_date(date))

        date = "10000-01-01T00:00:00.001+01:00"
        self.assertFalse(self.vimb._check_date(date))

        date = "900-01-01T00:00:00.001+01:00"
        self.assertFalse(self.vimb._check_date(date))

    def test_good_year(self):
        """
        Test date with correct years
        """
        date = "0001-01-01T00:00:00.001+01:00"
        self.assertTrue(self.vimb._check_date(date))

        date = "9999-01-01T00:00:00.001+01:00"
        self.assertTrue(self.vimb._check_date(date))


class TestAuthorize(unittest.TestCase):
    """
    Test method VimBlogger._authorize
    """
    def setUp(self):
        """
        Create VimBlogger object (with good credentials, yes :>)
        """
        self.vimob = VimBlogger(None, shared.LOGIN, shared.PASS)

    def test_happy_case(self):
        """
        Try to login with good credentials
        """
        self.assertTrue(self.vimob._authorize(shared.LOGIN,
                                              shared.PASS) is None)

    def test_wrong_login(self):
        """
        Try to login with wrong login
        """
        self.assertRaises(shared.BadAuthentication, self.vimob._authorize,
                          'joe', shared.PASS)

    def test_wrong_pass(self):
        """
        Try to login with wrong password
        """
        self.assertRaises(shared.BadAuthentication, self.vimob._authorize,
                          'joe', shared.PASS)


class TestAddTag(unittest.TestCase):
    """
    Test method VimBlogger._add_tag
    """
    def setUp(self):
        """
        Create VimBlogger object
        """
        self.vimob = VimBlogger(None, shared.LOGIN, shared.PASS)
        self.post = shared.MockPost()

    def test_add_tag(self):
        """
        Add items to existing categories. List should be uniq.
        """
        self.vimob._add_tag(self.post, 'item')
        self.assertTrue(len(self.post.category) == 1)

        # Item number should not change on the same label
        self.vimob._add_tag(self.post, 'item')
        self.assertTrue(len(self.post.category) == 1)

        self.vimob._add_tag(self.post, 'item2')
        self.assertTrue(len(self.post.category) == 2)


class TestExtractDate(unittest.TestCase):
    """
    Test method VimBlogger._extract_date
    """
    def setUp(self):
        """
        Create VimBlogger object
        """
        self.vimob = VimBlogger(None, shared.LOGIN, shared.PASS)

    def test_extract_date(self):
        """
        Date should be already verified by _check_date method, so only
        extraction is tested
        """
        date = "2000-01-01T00:00:00.001-10:00"

        # wrong scenario
        self.assertFalse(self.vimob._extract_date('wrong_date_string'))

        # only date should be returned
        self.assertEqual(self.vimob._extract_date(date), "2000-01-01")

        # date and time should be returned
        self.assertEqual(self.vimob._extract_date(date, True),
                         "2000-01-01 00:00:00")


class TestGetPost(unittest.TestCase):
    """
    Test method VimBlogger._get_post
    """
    def setUp(self):
        """
        Create VimBlogger object
        """
        self.vimob = VimBlogger(None, shared.LOGIN, shared.PASS)
        self.vimob.blog = shared.Mock()

        link = shared.Mock()
        link.href = "mock.com"
        link.feed = shared.Mock()

        self.vimob.blog.get_post_link = lambda: link

    def test_get_post(self):
        """
        Nothing really to test here. Maybe in the future :)
        """
        result = self.vimob._get_post('1234')
        self.assertEqual(type(result), shared.MockPost)


class TestSetBlog(unittest.TestCase):
    """
    Test method VimBlogger._set_blog
    """
    def setUp(self):
        """
        Create VimBlogger object
        """
        self.vimob = VimBlogger(None, shared.LOGIN, shared.PASS)
        for bid, bname in {1: 'one', 3: 'test', 7: 'blog_name'}.items():
            blog = shared.MockBlog(bname, bid)
            self.vimob.feed.entry.append(blog)

    def test_set_blog(self):
        """
        Test setting a blog
        """
        self.vimob._set_blog("no_valid_blog_name")
        self.assertEqual(self.vimob.blog_id, None)
        self.assertEqual(self.vimob.blog, None)

        self.vimob._set_blog("blog_name")
        self.assertEqual(self.vimob.blog_id, 7)
        self.assertEqual(self.vimob.blog.get_blog_name(), 'blog_name')

        self.vimob._set_blog("test")
        self.assertEqual(self.vimob.blog_id, 3)
        self.assertEqual(self.vimob.blog.get_blog_name(), 'test')

        self.vimob._set_blog("one")
        self.assertEqual(self.vimob.blog_id, 1)
        self.assertEqual(self.vimob.blog.get_blog_name(), 'one')


class TestCreateArticle(unittest.TestCase):
    """
    Test method VimBlogger.create_article
    """
    def setUp(self):
        """
        Create VimBlogger object
        """
        self.vimob = VimBlogger(None, shared.LOGIN, shared.PASS)

    def test_create_simple_article(self):
        """
        Test creation of article with minimum requirements
        """
        html = "<p>article</p>"
        post = self.vimob.create_article(html)
        self.vimob.draft = True

        self.assertEqual(post.id.text, '1234567890')
        self.assertEqual(post.content.text, html)
        self.assertEqual(post.published, None)
        self.assertTrue(post.updated is not None)
        self.assertEqual(post.title.text, "")
        self.assertEqual(post.category, [])
        self.assertEqual(post.control.draft.text, "yes")

    def test_create_article(self):
        """
        Test creation of article with full attrs
        """
        html = u"<p>article \xe2\x80\x94 article</p>"
        labels = "tag with spaces|vim|python|blogger".split("|")
        attrs = {"title":  u'Title \xe2\x80\x94 title',
                 "tags": ", ".join(labels),
                 "date": "2010-12-10T14:18:32+00:00"}
        self.vimob.draft = False

        post = self.vimob.create_article(html, attrs)
        self.assertEqual(post.id.text, '1234567890')
        self.assertEqual(post.content.text, html)
        self.assertEqual(post.published.text, attrs['date'])
        self.assertTrue(post.updated is not None)
        self.assertEqual(post.title.text, attrs['title'])
        self.assertEqual(len(post.category), 4)

        for label in post.category:
            self.assertTrue(label.term in labels)
            del(labels[labels.index(label.term)])

        self.assertEqual(post.control, None)


class TestDeleteArticle(unittest.TestCase):
    """
    Test method VimBlogger.create_article
    """
    def setUp(self):
        """
        Create VimBlogger object
        """
        self.vimob = VimBlogger(None, shared.LOGIN, shared.PASS)
        for bid, bname in {1: 'one', 3: 'test', 7: 'blog_name'}.items():
            blog = shared.MockBlog(bname, bid)
            self.vimob.feed.entry.append(blog)
        self.vimob._set_blog('test')

    def test_delete_non_existing_article(self):
        """
        Test removing article without id
        """
        self.assertEqual(self.vimob.delete_article(None),
                         "No article id provided")

    def test_delete_article(self):
        """
        Test removing article
        """
        html = u"<p>article \xe2\x80\x94 article</p>"
        labels = "tag with spaces|vim|python|blogger".split("|")
        attrs = {"title":  u'Title \xe2\x80\x94 title',
                 "tags": ", ".join(labels),
                 "date": "2010-12-10T14:18:32+00:00"}
        self.vimob.draft = False

        post = self.vimob.create_article(html, attrs)
        self.assertEqual(self.vimob.delete_article(post.id.text), None)


class TestGetArticles(unittest.TestCase):
    """
    Test method VimBlogger.get_articles
    """
    def setUp(self):
        """
        Create VimBlogger object
        """
        self.vimob = VimBlogger(None, shared.LOGIN, shared.PASS)

    def test_get_articles(self):
        """
        Test removing article without id
        """
        articles = self.vimob.get_articles()
        self.assertEqual(len(articles), 4)

        articles = self.vimob.get_articles(maxarticles=2)
        self.assertEqual(len(articles), 2)


class TestUpdateArticle(unittest.TestCase):
    """
    Test method VimBlogger.update_article
    """
    def setUp(self):
        """
        Create VimBlogger object
        """
        self.vimob = VimBlogger(None, shared.LOGIN, shared.PASS)
        for bid, bname in {1: 'one', 3: 'test', 7: 'blog_name'}.items():
            blog = shared.MockBlog(bname, bid)
            self.vimob.feed.entry.append(blog)
        self.vimob._set_blog('test')

    def test_wrong_argument_types(self):
        """
        Test update_article method with wrong argument types
        """
        self.assertRaises(TypeError, self.vimob.update_article, None, None)

    def test_no_id_in_attrs(self):
        """
        Test update_article method with no id in attrs
        """
        self.assertRaises(Exception, self.vimob.update_article,
                          '<p>update</p>', [])

    def test_update(self):
        """
        Test update_article method with no id in attrs
        """
        attrs = {'id': 1234567890, 'title': 'update',
                 'date': '2001-01-01T00:02:19.001+01:00',
                 'tags': "tag1, tag2, tag3"}
        post = self.vimob.update_article('<p>update</p>', attrs)

        self.assertEqual(post.title.text, 'update')
        self.assertEqual(post.id.text, '1234567890')
        self.assertEqual(post.content.text, '<p>update</p>')
        self.assertTrue(post.updated.text is not None)


if __name__ == "__main__":
    unittest.main()
