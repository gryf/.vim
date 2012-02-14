let current_file = expand('%:p')

if match(current_file, '\cicard') < 0
    ru! indent/python_pep8.vim
else
    let g:pep8_exclude=['W191']
    ru! indent/python.vim
endif
