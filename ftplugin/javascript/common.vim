setlocal foldmethod=syntax
setlocal list

" reformat json struct
map <leader>] <esc>:%!python -m json.tool<cr>
