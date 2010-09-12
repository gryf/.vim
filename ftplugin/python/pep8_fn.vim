" File: pep8_fn.vim
" Author: Roman 'gryf' Dobosz (gryf73 at gmail.com)
" Version: 1.0
" Last Modified: 2010-09-12
"
" Overview
" --------
" This plugin provides functionality to static checks for python files
" regarding PEP8 guidance[1] as ":Pep8" command.
"
" This function does not use pep8[2] command line utility, but relies on pep8
" module.
"
" This script uses python, therefore VIm should be compiled with python
" support. You can check it by issuing ":version" command, and search for
" "+python" inside features list.
"
" Couple of ideas was taken from pyflakes.vim[3] plugin.
"
" Installation
" ------------
" 1. Copy the pep8_fn.vim file to the $HOME/.vim/ftplugin/python or
"    $HOME/vimfiles/ftplugin/python or $VIM/vimfiles/ftplugin/python
"    directory. If python directory doesn't exists, it should be created.
"    Refer to the following Vim help topics for more information about Vim
"    plugins:
"       :help add-plugin
"       :help add-global-plugin
"       :help runtimepath
" 2. It should be possible to import pep8 from python interpreter (it should
"    report no error):
"    >>> import pep8
"    >>>
"    If there are errors, install pep8 first. Simplest way to do it, is to
"    use easy_install[4] shell command as a root:
"    # easy_install pep8
" 3. Restart Vim.
" 4. You can now use the ":Pep8" which will examine current python buffer
"    and open quickfix buffer with errors if any.
"
" [1] http://www.python.org/dev/peps/pep-0008/
" [2] http://pypi.python.org/pypi/pep8
" [3] http://www.vim.org/scripts/script.php?script_id=2441
" [4] http://pypi.python.org/pypi/setuptools

if exists("b:did_pep8_plugin")
    finish " only load once
else
    let b:did_pep8_plugin = 1
endif

if !exists("b:did_pep8_init")
    let b:did_pep8_init = 0

    if !has('python')
        echoerr "Error: the pep8_fn.vim plugin requires Vim to be compiled with +python"
        finish
    endif

    python << EOF
import vim
import sys
from StringIO import StringIO

try:
    import pep8
except ImportError:
    raise AssertionError('Error: pep8_fn.vim requires module pep8')

class VImPep8(object):

    def __init__(self):
        self.fname = vim.current.buffer.name
        self.bufnr = vim.current.buffer.number
        self.output = []

    def reporter(self, lnum, col, text, check):
        self.output.append([lnum, col, text])

    def run(self):
        pep8.process_options(['-r', vim.current.buffer.name])
        checker = pep8.Checker(vim.current.buffer.name)
        checker.report_error = self.reporter
        checker.check_all()
        self.process_output()

    def process_output(self):
        vim.command('call setqflist([])')
        qf_list = []
        qf_dict = {}

        for line in self.output:
            qf_dict['bufnr'] = self.bufnr
            qf_dict['lnum'] = line[0]
            qf_dict['col'] = line[1]
            qf_dict['text'] = line[2]
            qf_dict['type'] = line[2][0]
            qf_list.append(qf_dict)
            qf_dict = {}

        self.output = []
        vim.command('call setqflist(%s)' % str(qf_list))
        if qf_list:
            vim.command('copen')
EOF
    let b:did_pep8_init = 1
endif

if !exists('*s:Pep8')
    function s:Pep8()
        python << EOF
VImPep8().run()
EOF
    endfunction
endif

if !exists(":Pep8")
    command Pep8 call s:Pep8()
endif
