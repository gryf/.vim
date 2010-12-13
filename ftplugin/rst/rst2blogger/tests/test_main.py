# vim: set fileencoding=utf-8
import os
import sys
import unittest
import webbrowser

webbrowser.open = lambda x: None

this_dir = os.path.dirname(os.path.abspath(__file__))
this_dir = os.path.abspath(os.path.join(this_dir, "../.."))
sys.path.insert(0, this_dir)

from rst2blogger.tests.shared import LOGIN, PASS, Eval, MockBuffer
from rst2blogger.main import Rst2Blogger
from gdata.client import BadAuthentication


class TestRst2Blogger(unittest.TestCase):
    """
    Tests for vim - rest - blogger interface
    """
    def setUp(self):
        """
        Create Rst2Blogger object
        """
        self.obj = Rst2Blogger()

    def test_object_creation(self):
        """
        Create Rst2Blogger object and test it.
        """
        self.assertTrue(self.obj is not None)
        self.assertEqual(self.obj.docinfo_len, 3)
        self.assertEqual(self.obj.login, "")
        self.assertEqual(self.obj.password, "")
        self.assertEqual(self.obj.blogname, "")
        self.assertEqual(self.obj.buffer_encoding, "")
        self.assertEqual(self.obj.vim_encoding, "")
        self.assertEqual(self.obj.maxarticles, 0)
        self.assertEqual(self.obj.draft, 0)
        self.assertEqual(self.obj.confirm_del, 0)
        self.assertEqual(self.obj.stylesheets, [])


class TestRst2BloggerSetDocinfoLen(unittest.TestCase):
    """
    Test _set_docinfo_len method on different docinfo configurations
    """
    def setUp(self):
        """
        Create Rst2Blogger object
        """
        self.obj = Rst2Blogger()

    def test_set_docinfo_len(self):
        """
        Test with no defined docinfo
        """
        self.obj.buff = self.obj.buff[4:]
        self.obj._set_docinfo_len()
        self.assertEqual(self.obj.docinfo_len, 0)

    def test_set_docinfo_len2(self):
        """
        Test with one docinfo entry
        """
        self.obj.buff = self.obj.buff[:1] + [''] + self.obj.buff[4:]
        self.obj._set_docinfo_len()
        self.assertEqual(self.obj.docinfo_len, 1)

    def test_set_docinfo_len3(self):
        """
        Test with wrong docinfo definition
        """
        self.obj.buff = self.obj.buff[:1] + self.obj.buff[4:]
        self.obj._set_docinfo_len()
        self.assertEqual(self.obj.docinfo_len, 0)


class TestCheckHtml(unittest.TestCase):
    """
    Check HTML parser
    """
    def setUp(self):
        """
        Create Rst2Blogger object
        """
        self.obj = Rst2Blogger()

    def test_check_html1(self):
        """
        Parse (generated) html string, should return empty string
        """
        html = "<html><head><title>test</title></head><body></body></html>"
        self.assertEqual(self.obj._check_html(html), "")
        self.assertEqual(self.obj._check_html(html, True), "")

    def test_check_html2(self):
        """
        Parse html fragment string
        """
        html = "<p>first paragraph</p><p>another paragraph</p>"
        self.assertEqual(self.obj._check_html(html),
                         "junk after document element: line 1, column 22")
        self.assertEqual(self.obj._check_html(html, True), "")

    def test_check_html3(self):
        """
        Parse wrong html string (crossed tags)
        """
        html = "<p>first paragraph<b></p>another paragraph</b>"
        self.assertEqual(self.obj._check_html(html),
                         "mismatched tag: line 1, column 23")
        self.assertEqual(self.obj._check_html(html, True),
                         "mismatched tag: line 1, column 28")


class TestRst2BloggerDelete(unittest.TestCase):
    """
    Test delete method
    """
    def setUp(self):
        """
        Create Rst2Blogger object
        """
        self.obj = Rst2Blogger()
        self.obj.login = LOGIN
        self.obj.password = PASS
        self.obj.blogname = "test"
        self.obj.vim_encoding = "utf-8"

    def test_delete_without_password(self):
        """
        Delete article, while password is incorrect/nonexistend
        """
        self.obj.password = ""
        self.assertRaises(BadAuthentication, self.obj.delete)

    def test_delete(self):
        """
        Delete article. Set confirmation attribute.
        """
        self.obj.confirm_del = 1
        Eval.value = 2  # set choice to answer "Y" for confirmation
        Eval.blog = "test"
        self.assertEqual(self.obj.delete(), "Article deleted")

    def test_delete2(self):
        """
        Delete article. Set confirmation attribute. Refuse to delete.
        """
        self.obj.confirm_del = 1
        Eval.value = 1  # set choice to answer "N" for confirmation
        Eval.blog = "test"
        self.assertEqual(self.obj.delete(), "No articles deleted")

    def test_delete3(self):
        """
        Delete article. Unset confirmation attribute. Delete returns something
        else then None.
        """
        Eval.value = 2
        Eval.blog = "test"
        Eval.gdata_delete = 1
        self.assertEqual(self.obj.delete(), "Article deleted")


class TestRst2BloggerPost(unittest.TestCase):
    """
    Test post method
    """
    def setUp(self):
        """
        Create Rst2Blogger object
        """
        self.obj = Rst2Blogger()
        self.obj.login = LOGIN
        self.obj.password = PASS
        self.obj.blogname = "test"
        self.obj.vim_encoding = "utf-8"
        self.obj.buffer_encoding = "utf-8"
        # create copy of the buffer list and assign copy to the buff attribute
        self._rest = MockBuffer(self.obj.buff[:])
        self.obj.buff = self._rest

    def test_without_password(self):
        """
        Post article, while password is incorrect/nonexistend
        """
        self.obj.password = ""
        self.assertRaises(BadAuthentication, self.obj.post)

    def test_with_wrong_data(self):
        """
        Try to post not well formed html
        """
        self.obj.buff.append('')
        self.obj.buff.append('.. raw:: html')
        self.obj.buff.append('')
        self.obj.buff.append('    <p>foo<b>bar</p>baz</b>')
        self.obj.buff.append('')
        self.obj.post()
        self.assertEqual(self.obj.post(),
                         'There are errors in generated document')

    def test_post_create(self):
        """
        Try to post well formed html, as a new article
        """
        self.assertEqual(self.obj.post(),
                         'New article with id 1234567890 has been created')

    def test_post_update(self):
        """
        Try to post well formed html, as a new article
        """
        self.obj.buff.append(':Id: 1234567890', 0)
        self.assertEqual(self.obj.post(),
                         "Article 'Title \xe2\x80\x94 This is a test' "
                         "has been updated")


class TestRst2BloggerUpdateDocinfo(unittest.TestCase):
    """
    Test _update_docinfo
    """
    def setUp(self):
        """
        Create Rst2Blogger object
        """
        self.obj = Rst2Blogger()
        self.obj.login = LOGIN
        self.obj.password = PASS
        self.obj.blogname = "test"
        self.obj.vim_encoding = "utf-8"
        self.obj.buffer_encoding = "utf-8"
        # create copy of the buffer list and assign copy to the buff attribute
        self._rest = MockBuffer(self.obj.buff[:])
        self.obj.buff = self._rest

    def test_with_empty_docinfo(self):
        """
        Try to post not well formed html
        """
        self.obj.buff = MockBuffer(self.obj.buff[4:])
        self.obj.docinfo_len = 0
        self.obj._update_docinfo('title', 'title2')


class TestRst2BloggerPreview(unittest.TestCase):
    """
    Test preview
    """
    def setUp(self):
        """
        Create Rst2Blogger object
        """
        self.obj = Rst2Blogger()
        self.obj.login = LOGIN
        self.obj.password = PASS
        self.obj.blogname = "test"

    def tearDown(self):
        """
        Remove leftovers in fs
        """
        try:
            os.unlink(self.obj.buff.name[:-4])
        except OSError:
            pass
        try:
            os.unlink(self.obj.buff.name[:-4] + ".html")
        except OSError:
            pass

    def test_preview_open_in_browser(self):
        """
        Try to post not well formed html
        """
        Eval.value = 1
        print self.obj.preview()

    def test_preview_save_to_file(self):
        """
        Try to post not well formed html
        """
        Eval.value = 0
        name = self.obj.buff.name[:-4] + ".html"
        self.assertEqual(self.obj.preview(),
                         "Generated HTML has been written to %s" % name)


if __name__ == "__main__":
    unittest.main()
