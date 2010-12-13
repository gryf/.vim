# vim: set fileencoding=utf-8
import os
import sys
import unittest
import re

this_dir = os.path.dirname(os.path.abspath(__file__))
this_dir = os.path.abspath(os.path.join(this_dir, "../.."))
sys.path.insert(0, this_dir)

from rst2blogger.rest import blogArticleString, blogPreview
from rst2blogger.tests.shared import REST_ARTICLE


class TestBlogPreview(unittest.TestCase):
    """
    Test generating HTML out of prepared reST text. It tests only for some
    aspects of the entire thing, because it is not intendend to test all of
    reST directives.
    """
    def test_content(self):
        """
        Simple case, check output
        """
        html_out = blogPreview(REST_ARTICLE)
        self.assertTrue(len(html_out) > 0)
        self.assertTrue("<html" in html_out)
        self.assertTrue("</html>" in html_out)
        self.assertTrue("<?xml version=\"1.0\" encoding=\"utf-8\"" in
                        html_out)
        self.assertTrue("\n\n<!-- more -->\n\n" in html_out)
        self.assertTrue("<title>Title — This is a test</title>" in html_out)
        self.assertTrue('type="text/css"' not in html_out)
        self.assertTrue(re.search(r"<h1.*><a href=\"#\">Title — This is a"
                                  " test</a></h1>", html_out))
        self.assertTrue(re.search(r"<h2>Section 1</h2>", html_out))
        self.assertTrue(re.search(r"<h3>Subsection 1.1</h3>", html_out))
        self.assertTrue("description" not in html_out)

    def test_stylesheets(self):
        """
        Test output for stylesheets
        """
        html_out = blogPreview(REST_ARTICLE, ["css/style1.css",
                                              "css/blogger1.css"])
        self.assertTrue('type="text/css"' in html_out)
        match = re.search(r'<link rel="stylesheet" '
                          'href=".*" type="text/css" />', html_out)
        self.assertTrue(match is not None)
        self.assertEqual(len(match.span()), 2)


class TestBlogArticleString(unittest.TestCase):
    """
    Test blogArticleString function, wich should return part of html and
    dictionary with attributes.
    """
    def test_blogArticleString(self):
        html_out, attrs = blogArticleString(REST_ARTICLE)
        self.assertEqual(len(attrs), 3)
        self.assertTrue(len(html_out) > 0)
        self.assertTrue("<html" not in html_out)
        self.assertTrue("</html>" not in html_out)
        self.assertTrue("<?xml version=\"1.0\" encoding=\"utf-8\"" not in
                        html_out)
        self.assertTrue("\n\n<!-- more -->\n\n" in html_out)
        self.assertTrue("<title>Title — This is a test</title>" not in
                        html_out)
        self.assertTrue('type="text/css"' not in html_out)
        self.assertTrue(re.search(r"<h4>Section 1</h4>", html_out))
        self.assertTrue(re.search(r"<h5>Subsection 1.1</h5>", html_out))
        self.assertTrue("description" not in html_out)

        self.assertEqual(attrs['title'], u"Title — This is a test")
        self.assertEqual(attrs['date'], "2010-12-12T12:36:36+01:00")
        self.assertEqual(attrs['tags'], "this is a test, Blogger, rest")

if __name__ == "__main__":
    unittest.main()
