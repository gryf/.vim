#!/usr/bin/env python
"""
This script can be used as a pylint command replacement, especially useful as
a "make" command for VIm
"""
import sys
import re
from cStringIO import StringIO
from optparse import OptionParser

from pylint import lint
from pylint.reporters.text import TextReporter


SYS_STDERR = sys.stderr
DUMMY_STDERR = StringIO()
CONF_MSG = 'No config file found, using default configuration\n'

def parsable_pylint(filename):
    """
    Simple wrapper for pylint checker. Provides nice, parseable output.
    filename - python fileneame to check

    Returns list of dicts of errors, i.e.:
    [{'lnum': 5, 'col': 10, 'type': 'C0324',
      'text': 'Comma not followed by a space'},
     {'lnum': 12, 'type': 'C0111', 'text': 'Missing docstring'},
     ....
    ]

    """
    # module args
    margs = ['-rn',  # display only the messages instead of full report
             '-iy',  # Include message's id in output
             filename]

    buf = StringIO()  # file-like buffer, instead of stdout
    reporter = TextReporter(buf)

    sys.stderr = DUMMY_STDERR
    lint.Run(margs, reporter=reporter, exit=False)
    sys.stderr = SYS_STDERR

    # see, if we have other errors than 'No config found...' message
    DUMMY_STDERR.seek(0)
    error_list = DUMMY_STDERR.readlines()
    DUMMY_STDERR.truncate(0)
    if error_list and CONF_MSG in error_list:
        error_list.remove(CONF_MSG)
        if error_list:
            raise Exception(''.join(error_list))

    buf.seek(0)

    code_line = {}
    error_list = []

    carriage_re = re.compile(r'\s*\^+$')
    error_re = re.compile(r'^([C,R,W,E,F].+):(\s+)?([0-9]+):?.*:\s(.*)$')

    for bufline in buf:
        bufline = bufline.rstrip()  # remove trailing newline character

        if error_re.match(bufline):
            if code_line:
                error_list.append(code_line)
                code_line = {}

            (code_line['type'], _unused, code_line['lnum'],
             code_line['text']) = error_re.match(bufline).groups()

        if carriage_re.match(bufline) and code_line:
            code_line['col'] = carriage_re.match(bufline).group().find('^') + 1

    return error_list

if __name__ == "__main__":
    PARSER = OptionParser("usage: %prog python_file")
    (OPTIONS, args) = PARSER.parse_args()
    if len(args) == 1:
        for line in parsable_pylint(args[0]):
            line['short'] = line['type'][0]
            line['fname'] = args[0]
            out = "%(fname)s: %(short)s: %(lnum)s: %(col)s: %(type)s %(text)s"
            if 'col' not in line:
                out = "%(fname)s: %(short)s: %(lnum)s: 0: %(type)s %(text)s"

            print out % line
