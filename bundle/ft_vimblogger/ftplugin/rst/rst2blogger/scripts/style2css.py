#!/usr/bin/env python
"""
Generate CSS stylesheet out of provided Style class module, which is an output
from the vim2pygments.py[1] script.

That stylesheet (with any necessary, additional modifications) can be used
with vimblogger_ft[2] VIm plugin, but also for general pygments usage.

Usage:
    style2css <module>

[1] vim2pygments is part of the Pygments module, and can be found in scripts
    directory of the Pygments <http://pygments.org> distribution.
[2] <http://www.vim.org/scripts/script.php?script_id=3367>
"""

import optparse
import os

from pygments.formatters import HtmlFormatter


class Pygments2CSS(object):
    def __init__(self, modulefn, cssclass):
        self.style_class = None
        self.cssclass = cssclass
        if not self.cssclass.startswith("."):
            self.cssclass = "." + self.cssclass

        mod = os.path.splitext(os.path.basename(modulefn))[0]

        try:
            module = __import__("%s" % mod)
        except ImportError:
            print('Error: %s should be in PYTHONPATH or current'
                  ' directory, and should contain valid Style derived'
                  ' class' % modulefn)
            raise

        for item in dir(module):
            if item != 'Style' and item.endswith('Style'):
                self.style_class = getattr(module, item)
                break
        else:
            raise ValueError("Error: Wrong module?")

    def out(self):
        formatter = HtmlFormatter(style=self.style_class)
        print "%s { background-color: %s }" % \
                (self.cssclass, self.style_class.background_color)
        for line in formatter.get_style_defs().split("\n"):
            print "%s" % self.cssclass, line

if __name__ == "__main__":
    parser = optparse.OptionParser("usage: %prog [options] stylefile.py\n"
                                   "Where stylefile.py is a product of the"
                                   " vim2pygments.py script Pygments "
                                   "distribution.")
    parser.add_option("-c", "--class",
                      dest="cssclass",
                      type="str",
                      help="Main CSS class name. Defaults to 'syntax'",
                      default="syntax")
    (options, args) = parser.parse_args()

    if len(args) != 1:
        parser.error("stylefile.py is required")

    if not (os.path.exists(args[0]) and os.path.isfile(args[0])):
        parser.error("%s not found" % args[0])

    p2css = Pygments2CSS(args[0], options.cssclass)
    p2css.out()
