" File: pythonlint.vim
" Author: Roman 'gryf' Dobosz (gryf73 at gmail.com)
" Version: 1.0
" Last Modified: 2010-09-11
"
" Overview
" --------
" This plugin provides ":Pylint" command, which put pylint result into quickfix
" buffer. This function does not uses pylint[1] command line utility, only
" python pylint.lint module is used instead. So it makes the pylint
" egg/package required for running this script.
"
" This script uses python, therefore VIm should be compiled with python
" support. You can check it by issuing ":version" command, and search for
" "+python" inside features list.
"
" Couple of ideas was taken from pyflakes.vim[2] plugin.
"
" Installation
" ------------
" 1. Copy the pythonlint.vim file to the $HOME/.vim/ftplugin/python or
"    $HOME/vimfiles/ftplugin/python or $VIM/vimfiles/ftplugin/python
"    directory. If python directory doesn't exists, it should be created.
"    Refer to the following Vim help topics for more information about Vim
"    plugins:
"       :help add-plugin
"       :help add-global-plugin
"       :help runtimepath
" 2. It should be possible to import pylint from python interpreter (it should
"    report no error):
"    >>> import pylint
"    >>>
"    If there are errors, install pylint first. Simplest way to do it, is to
"    use easy_install[3] shell command as a root:
"    # easy_install pylint
" 3. Restart Vim.
" 4. You can now use the ":Pylint" which will examine current python buffer
"    and open quickfix buffer with errors if any.
"
" [1] http://www.logilab.org/project/pylint
" [2] http://www.vim.org/scripts/script.php?script_id=2441
" [3] http://pypi.python.org/pypi/setuptools

if exists("b:did_pylint_plugin")
    finish " only load once
else
    let b:did_pylint_plugin = 1
endif

if !exists("b:did_pylint_init")
    let b:did_pylint_init = 0

    if !has('python')
        echoerr "Error: the pythonlint.vim plugin requires Vim to be compiled with +python"
        finish
    endif

    python << EOF
import vim
import sys
from StringIO import StringIO

try:
    from pylint import lint
    from pylint.reporters.text import TextReporter
except ImportError:
    raise AssertionError('Pylint is required for this plugin')

class VImPylint(object):

    sys_stderr = sys.stderr
    dummy_stderr = StringIO()
    conf_msg = 'No config file found, using default configuration\n'

    @classmethod
    def run(self):
        """execute pylint and fill the quickfix"""

        # clear QF window
        vim.command('call setqflist([])')

        # args
        args = ['-rn',  # display only the messages instead of full report
                '-iy',  # Include message's id in output
                vim.current.buffer.name]

        buf = StringIO()  # file-like buffer, instead of stdout
        reporter = TextReporter(buf)

        sys.stderr = self.dummy_stderr
        lint.Run(args, reporter=reporter, exit=False)
        sys.stderr = self.sys_stderr

        self.dummy_stderr.seek(0)
        error_list = self.dummy_stderr.readlines()
        self.dummy_stderr.truncate(0)
        if error_list and self.conf_msg in error_list:
            error_list.remove(self.conf_msg)
            if error_list:
                raise Exception(''.join(error_list))

        buf.seek(0)

        bufnr = vim.current.buffer.number
        code_line = {}
        error_list = []

        carriage_re = re.compile(r'\s*\^+$')
        error_re = re.compile(r'^([C,R,W,E,F].+):\s+?([0-9]+):?.*:\s(.*)$')

        for line in buf:
            line = line.rstrip()  # remove trailing newline character

            if error_re.match(line):
                if code_line:
                    code_line['bufnr'] = bufnr
                    error_list.append(code_line)
                    code_line = {}

                code_line['type'], code_line['lnum'], code_line['text'] = \
                        error_re.match(line).groups()

            if carriage_re.match(line) and code_line:
                code_line['col'] = carriage_re.match(line).group().find('^') \
                    + 1
        vim.command('call setqflist(%s)' % str(error_list))
        if error_list:
            vim.command('copen')
EOF
    let b:did_pylint_init = 1
endif

if !exists('*s:Pylint')
    function s:Pylint()
        python << EOF
VImPylint.run()
EOF
    endfunction
endif

if !exists(":Pylint")
    command Pylint call s:Pylint()
endif