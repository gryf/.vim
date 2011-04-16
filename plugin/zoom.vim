if &cp || exists("g:loaded_zoom")
    finish
endif
let g:loaded_zoom = 1

let s:save_cpo = &cpo
set cpo&vim

" keep default value
let s:current_font = &guifont

" command
command! -narg=0 ZoomIn    :call s:ZoomIn()
command! -narg=0 ZoomOut   :call s:ZoomOut()
command! -narg=0 ZoomReset :call s:ZoomReset()

" map
nmap <kPlus> :ZoomIn<CR>
nmap <kMinus> :ZoomOut<CR>
nmap <kDivide> :ZoomReset<CR>

" guifont size + 1
function! s:ZoomIn()
  let l:font = split(&guifont)
  let l:size = l:font[1] + 1
  let &guifont = l:font[0] . " " . l:size
endfunction

" guifont size - 1
function! s:ZoomOut()
  let l:font = split(&guifont)
  let l:size = l:font[1] - 1
  let &guifont = l:font[0] . " " . l:size
endfunction

" reset guifont size
function! s:ZoomReset()
  let &guifont = s:current_font
endfunction

let &cpo = s:save_cpo
finish

==============================================================================
zoom.vim : control gui font size with "+" or "-" keys.
------------------------------------------------------------------------------
$VIMRUNTIMEPATH/plugin/zoom.vim
==============================================================================
author  : OMI TAKU
url     : http://nanasi.jp/
email   : mail@nanasi.jp
version : 2008/07/18 10:00:00
==============================================================================

Control Vim editor font size with key "+", or key "-".
Press "+" key, Vim editor gui font size will change bigger.
And, press "-" key, Vim editor gui font size will change smaller.

This plugin is for GUI only.


Normal Mode:
    +                  ... change font size bigger
    -                  ... change font size smaller

Command-line Mode:
    :ZoomIn            ... change font size bigger
    :ZoomOut           ... change font size smaller
    :ZoomReset         ... reset font size changes.

==============================================================================

1. Copy the zoom.vim script to
   $HOME/vimfiles/plugin or $HOME/.vim/plugin directory.
   Refer to ':help add-plugin', ':help add-global-plugin' and
   ':help runtimepath' for more details about Vim plugins.

2. Restart Vim.

==============================================================================
" vim: set ff=unix et ft=vim nowrap :
