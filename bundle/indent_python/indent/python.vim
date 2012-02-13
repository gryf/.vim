let current_file = expand('%:p')

if match(current_file, '\cicard') < 0
    source $HOME/.vim/indent/python_pep8.vim
else
    let g:pep8_exclude=['W191']
    source $VIMRUNTIME/indent/python.vim
endif
