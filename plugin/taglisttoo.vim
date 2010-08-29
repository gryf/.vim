" Author:  Eric Van Dewoestine
"
" Description: {{{
"   see http://eclim.org/vim/taglist.html
"
" License:
"
" Copyright (C) 2005 - 2010  Eric Van Dewoestine
"
" This program is free software: you can redistribute it and/or modify
" it under the terms of the GNU General Public License as published by
" the Free Software Foundation, either version 3 of the License, or
" (at your option) any later version.
"
" This program is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
" GNU General Public License for more details.
"
" You should have received a copy of the GNU General Public License
" along with this program.  If not, see <http://www.gnu.org/licenses/>.
"
" }}}
" eclim version: 1.6.0

if exists('g:taglisttoo_loaded') ||
   \ (exists('g:taglisttoo_disabled') && g:taglisttoo_disabled)
  finish
endif
let g:taglisttoo_loaded = 1

" Global Variables {{{

if !exists("g:TaglistEnabled")
  let g:TaglistEnabled = 1
endif

" always set the taglist title since eclim references it in a few places.
if !exists('g:TagList_title')
  let g:TagList_title = "__Tag_List__"
endif

if !g:TaglistEnabled
  finish
endif

" disable if user has taglist installed on windows since we can't hook into
" taglist to fix the windows path separators to be java compatible.
if exists('loaded_taglist') && (has('win32') || has('win64') || has('win32unix'))
  finish
endif

if !exists('g:Tlist_Ctags_Cmd')
  if executable('exuberant-ctags')
    let g:Tlist_Ctags_Cmd = 'exuberant-ctags'
  elseif executable('ctags')
    let g:Tlist_Ctags_Cmd = 'ctags'
  elseif executable('ctags.exe')
    let g:Tlist_Ctags_Cmd = 'ctags.exe'
  elseif executable('tags')
    let g:Tlist_Ctags_Cmd = 'tags'
  endif
endif

" no ctags found, no need to continue.
if !exists('g:Tlist_Ctags_Cmd')
  finish
endif

let g:Tlist_Ctags_Cmd_Ctags = g:Tlist_Ctags_Cmd

" don't conflict with original taglist if that is what the user is using.
if !exists('loaded_taglist')
  " Automatically open the taglist window on Vim startup
  if !exists('g:Tlist_Auto_Open')
    let g:Tlist_Auto_Open = 0
  endif

  if g:Tlist_Auto_Open && !exists('g:Tlist_Temp_Disable')
    augroup taglisttoo_autoopen
      autocmd!
      autocmd VimEnter * nested call s:AutoOpen()
    augroup END

    " Auto open on new tabs as well.
    if v:version >= 700
      autocmd taglisttoo_autoopen BufWinEnter *
        \ if tabpagenr() > 1 &&
        \     !exists('t:Tlist_Auto_Opened') &&
        \     !exists('g:SessionLoad') |
        \   call s:AutoOpen() |
        \   let t:Tlist_Auto_Opened = 1 |
        \ endif
    endif
  endif

  augroup taglisttoo_file_session
    autocmd!
    autocmd SessionLoadPost * call s:Restore()
  augroup END
endif
" }}}

" Command Declarations {{{
if !exists(":Tlist") && !exists(":TlistToo")
  "command TlistToo :call s:Taglist()
  "I want to have possibility to explicit close the taglist by passing bang to 
  "the command. gryf
  command! -bang -nargs=? TlistToo :call s:Taglist(<bang>-1)
  "And also have a command for explicit close
  command! TlistTooOpen :call s:Taglist(1)
endif
" }}}

" Util: {{{1

" Script Variables eclim/autoload/eclim/util.vim {{{2
  let s:buffer_write_closing_commands = '^\s*\(' .
    \ 'wq\|xa\|' .
    \ '\d*w[nN]\|\d*wp\|' .
    \ 'ZZ' .
    \ '\)'

  let s:bourne_shells = ['sh', 'bash', 'dash', 'ksh', 'zsh']
  let s:c_shells = ['csh', 'tcsh']

  let s:show_current_error_displaying = 0
" }}}

" DelayedCommand(command, [delay]) eclim/autoload/eclim/util.vim {{{2
" Executes a delayed command.  Useful in cases where one would expect an
" autocommand event (WinEnter, etc) to fire, but doesn't, or you need a
" command to execute after other autocommands have finished.
" Note: Nesting is not supported.  A delayed command cannot be invoke off
" another delayed command.
function! DelayedCommand(command, ...)
  let uid = fnamemodify(tempname(), ':t:r')
  if &updatetime > 1
    exec 'let g:eclim_updatetime_save' . uid . ' = &updatetime'
  endif
  exec 'let g:eclim_delayed_command' . uid . ' = a:command'
  let &updatetime = len(a:000) ? a:000[0] : 1
  exec 'augroup delayed_command' . uid
    exec 'autocmd CursorHold * ' .
      \ '  if exists("g:eclim_updatetime_save' . uid . '") | ' .
      \ '    let &updatetime = g:eclim_updatetime_save' . uid . ' | ' .
      \ '    unlet g:eclim_updatetime_save' . uid . ' | ' .
      \ '  endif | ' .
      \ '  exec g:eclim_delayed_command' . uid . ' | ' .
      \ '  unlet g:eclim_delayed_command' . uid . ' | ' .
      \ '  autocmd! delayed_command' . uid
  exec 'augroup END'
endfunction " }}}

" EchoTrace(message, [time_elapsed]) eclim/autoload/eclim/util.vim {{{2
function! EchoTrace(message, ...)
  if a:0 > 0
    call s:EchoLevel('(' . a:1 . 's) ' . a:message, 6, g:EclimTraceHighlight)
  else
    call s:EchoLevel(a:message, 6, g:EclimTraceHighlight)
  endif
endfunction " }}}

" EchoError(message) eclim/autoload/eclim/util.vim {{{2
function! EchoError(message)
  call s:EchoLevel(a:message, 2, g:EclimErrorHighlight)
endfunction " }}}

" s:EchoLevel(message) eclim/autoload/eclim/util.vim {{{2
" Echos the supplied message at the supplied level with the specified
" highlight.
function! s:EchoLevel(message, level, highlight)
  " only echo if the result is not 0, which signals that ExecuteEclim failed.
  if a:message != "0" && g:EclimLogLevel >= a:level
    exec "echohl " . a:highlight
    redraw
    for line in split(a:message, '\n')
      echom line
    endfor
    echohl None
  endif
endfunction " }}}

" EscapeBufferName(name) eclim/autoload/eclim/util.vim {{{2
" Escapes the supplied buffer name so that it can be safely used by buf*
" functions.
function! EscapeBufferName(name)
  let name = a:name
  " escaping the space in cygwin could lead to the dos path error message that
  " cygwin throws when a dos path is referenced.
  if !has('win32unix')
    let name = escape(a:name, ' ')
  endif
  return substitute(name, '\(.\{-}\)\[\(.\{-}\)\]\(.\{-}\)', '\1[[]\2[]]\3', 'g')
endfunction " }}}

" ExecWithoutAutocmds(cmd, [events]) eclim/autoload/eclim/util.vim {{{2
" Execute a command after disabling all autocommands (borrowed from taglist.vim)
function! ExecWithoutAutocmds(cmd, ...)
  let save_opt = &eventignore
  let events = len(a:000) == 0 ? 'all' : a:000[0]
  exec 'set eventignore=' . events
  try
    exec a:cmd
  finally
    let &eventignore = save_opt
  endtry
endfunction " }}}

" GetLineError(line) eclim/autoload/eclim/util.vim {{{2
" Gets the error (or message) for the supplie line number if one.
function! GetLineError(line)
  let line = line('.')
  let col = col('.')

  let errornum = 0
  let errorcol = 0
  let index = 0

  let locerrors = getloclist(0)
  let qferrors = getqflist()
  let bufname = expand('%')
  let lastline = line('$')
  for error in qferrors + locerrors
    let index += 1
    if bufname(error.bufnr) == bufname &&
        \ (error.lnum == line || (error.lnum > lastline && line == lastline))
      if errornum == 0 || (col >= error.col && error.col != errorcol)
        let errornum = index
        let errorcol = error.col
      endif
    endif
  endfor

  if errornum > 0
    let src = 'qf'
    let cnt = len(qferrors)
    let errors = qferrors
    if errornum > cnt
      let errornum -= cnt
      let src = 'loc'
      let cnt = len(locerrors)
      let errors = locerrors
    endif

    let message = src . ' - (' . errornum . ' of ' . cnt . '): '
      \ . substitute(errors[errornum - 1].text, '^\s\+', '', '')
    return message
  endif
  return ''
endfunction " }}}

" GoToBufferWindow(buf) eclim/autoload/eclim/util.vim {{{2
" Focuses the window containing the supplied buffer name or buffer number.
" Returns 1 if the window was found, 0 otherwise.
function! GoToBufferWindow(buf)
  if type(a:buf) == 0
    let winnr = bufwinnr(a:buf)
  else
    let name = EscapeBufferName(a:buf)
    let winnr = bufwinnr(bufnr('^' . name))
  endif
  if winnr != -1
    exec winnr . "winc w"
    call DelayedCommand('doautocmd WinEnter')
    return 1
  endif
  return 0
endfunction " }}}

" GoToBufferWindowRegister(buf) eclim/autoload/eclim/util.vim {{{2
" Registers the autocmd for returning the user to the supplied buffer when the
" current buffer is closed.
function! GoToBufferWindowRegister(buf)
  exec 'autocmd BufWinLeave <buffer> ' .
    \ 'call GoToBufferWindow("' . escape(a:buf, '\') . '") | ' .
    \ 'doautocmd BufEnter'
endfunction " }}}

" System(cmd, [exec]) eclim/autoload/eclim/util.vim {{{2
" Executes system() accounting for possibly disruptive vim options.
function! System(cmd, ...)
  let saveshell = &shell
  let saveshellcmdflag = &shellcmdflag
  let saveshellpipe = &shellpipe
  let saveshellquote = &shellquote
  let saveshellredir = &shellredir
  let saveshellslash = &shellslash
  let saveshelltemp = &shelltemp
  let saveshellxquote = &shellxquote

  if has("win32") || has("win64")
    set shell=cmd.exe
    set shellcmdflag=/c
    set shellpipe=>%s\ 2>&1
    set shellquote=
    set shellredir=>%s\ 2>&1
    set noshellslash
    set shelltemp
    set shellxquote=
  else
    if executable('/bin/bash')
      set shell=/bin/bash
    else
      set shell=/bin/sh
    endif
    set shell=/bin/sh
    set shellcmdflag=-c
    set shellpipe=2>&1\|\ tee
    set shellquote=
    set shellredir=>%s\ 2>&1
    set noshellslash
    set shelltemp
    set shellxquote=
  endif

  if len(a:000) > 0 && a:000[0]
    let result = ''
    let begin = localtime()
    try
      exec a:cmd
    finally
      call EchoTrace('exec: ' . a:cmd, localtime() - begin)
    endtry
  else
    let begin = localtime()
    try
      let result = system(a:cmd)
    finally
      call EchoTrace('system: ' . a:cmd, localtime() - begin)
    endtry
  endif

  let &shell = saveshell
  let &shellcmdflag = saveshellcmdflag
  let &shellquote = saveshellquote
  let &shellslash = saveshellslash
  let &shelltemp = saveshelltemp
  let &shellxquote = saveshellxquote

  " If a System call is executed at startup, it appears to interfere with
  " vim's setting of 'shellpipe' and 'shellredir' to their shell specific
  " values.  So, if we detect that the values we are restoring look like
  " uninitialized defaults, then attempt to mimic vim's documented
  " (:h 'shellpipe' :h 'shellredir') logic for setting the proper values based
  " on the shell.
  " Note: still doesn't handle more obscure shells
  if saveshellredir == '>'
    if index(s:bourne_shells, fnamemodify(&shell, ':t')) != -1
      set shellpipe=2>&1\|\ tee
      set shellredir=>%s\ 2>&1
    elseif index(s:c_shells, fnamemodify(&shell, ':t')) != -1
      set shellpipe=\|&\ tee
      set shellredir=>&
    else
      let &shellpipe = saveshellpipe
      let &shellredir = saveshellredir
    endif
  else
    let &shellpipe = saveshellpipe
    let &shellredir = saveshellredir
  endif

  return result
endfunction " }}}

" End Util: }}}

" TagListToo: {{{1

" Global Variables eclim/autoload/eclim/taglist/taglisttoo.vim {{{
let g:TagListToo = 1

" Tag listing sort type - 'name' or 'order'
if !exists('Tlist_Sort_Type')
  let Tlist_Sort_Type = 'order'
endif

" }}}

" Script Variables eclim/autoload/eclim/taglist/taglisttoo.vim {{{
  let s:taglisttoo_ignore = g:TagList_title . '\|ProjectTree'

  " used to prefer one window over another if a buffer is open in more than
  " one window.
  let s:taglisttoo_prevwinnr = 0
" }}}

" Language Settings eclim/autoload/eclim/taglist/taglisttoo.vim {{{
" assembly language
let s:tlist_def_asm_settings = {
    \ 'lang': 'asm', 'tags': {
      \ 'd': 'define',
      \ 'l': 'label',
      \ 'm': 'macro',
      \ 't': 'type'
    \ }
  \ }

" aspperl language
let s:tlist_def_aspperl_settings = {
    \ 'lang': 'asp', 'tags': {
      \ 'f': 'function',
      \ 's': 'sub',
      \ 'v': 'variable'
    \ }
  \ }

" aspvbs language
let s:tlist_def_aspvbs_settings = {
    \ 'lang': 'asp', 'tags': {
      \ 'f': 'function',
      \ 's': 'sub',
      \ 'v': 'variable'
    \ }
  \ }

" awk language
let s:tlist_def_awk_settings = {'lang': 'awk', 'tags': {'f': 'function'}}

" beta language
let s:tlist_def_beta_settings = {
    \ 'lang': 'beta', 'tags': {
      \ 'f': 'fragment',
      \ 's': 'slot',
      \ 'v': 'pattern'
    \ }
  \ }

" c language
let s:tlist_def_c_settings = {
    \ 'lang': 'c', 'tags': {
      \ 'd': 'macro',
      \ 'g': 'enum',
      \ 's': 'struct',
      \ 'u': 'union',
      \ 't': 'typedef',
      \ 'v': 'variable',
      \ 'f': 'function'
    \ }
  \ }

" c++ language
let s:tlist_def_cpp_settings = {
    \ 'lang': 'c++', 'tags': {
      \ 'n': 'namespace',
      \ 'v': 'variable',
      \ 'd': 'macro',
      \ 't': 'typedef',
      \ 'c': 'class',
      \ 'g': 'enum',
      \ 's': 'struct',
      \ 'u': 'union',
      \ 'f': 'function'
    \ }
  \ }

" c# language
let s:tlist_def_cs_settings = {
    \ 'lang': 'c#', 'tags': {
      \ 'd': 'macro',
      \ 't': 'typedef',
      \ 'n': 'namespace',
      \ 'c': 'class',
      \ 'E': 'event',
      \ 'g': 'enum',
      \ 's': 'struct',
      \ 'i': 'interface',
      \ 'p': 'properties',
      \ 'm': 'method'
    \ }
  \ }

" cobol language
let s:tlist_def_cobol_settings = {
    \ 'lang': 'cobol', 'tags': {
      \ 'd': 'data',
      \ 'f': 'file',
      \ 'g': 'group',
      \ 'p': 'paragraph',
      \ 'P': 'program',
      \ 's': 'section'
    \ }
  \ }

" eiffel language
let s:tlist_def_eiffel_settings = {
    \ 'lang': 'eiffel', 'tags': {
      \ 'c': 'class',
      \ 'f': 'feature'
    \ }
  \ }

" erlang language
let s:tlist_def_erlang_settings = {
    \ 'lang': 'erlang', 'tags': {
      \ 'd': 'macro',
      \ 'r': 'record',
      \ 'm': 'module',
      \ 'f': 'function'
    \ }
  \ }

" expect (same as tcl) language
let s:tlist_def_expect_settings = {
    \ 'lang': 'tcl', 'tags': {
      \ 'c': 'class',
      \ 'f': 'method',
      \ 'p': 'procedure'
    \ }
  \ }

" fortran language
let s:tlist_def_fortran_settings = {
    \ 'lang': 'fortran', 'tags': {
      \ 'p': 'program',
      \ 'b': 'block data',
      \ 'c': 'common',
      \ 'e': 'entry',
      \ 'i': 'interface',
      \ 'k': 'type',
      \ 'l': 'label',
      \ 'm': 'module',
      \ 'n': 'namelist',
      \ 't': 'derived',
      \ 'v': 'variable',
      \ 'f': 'function',
      \ 's': 'subroutine'
    \ }
  \ }

" HTML language
let s:tlist_def_html_settings = {
    \ 'lang': 'html', 'tags': {
      \ 'a': 'anchor',
      \ 'f': 'javascript function'
    \ }
  \ }

" java language
let s:tlist_format_java = 'FormatJava'
let s:tlist_def_java_settings = {
    \ 'lang': 'java', 'tags': {
      \ 'p': 'package',
      \ 'c': 'class',
      \ 'i': 'interface',
      \ 'f': 'field',
      \ 'm': 'method'
    \ }
  \ }

let s:tlist_format_javascript = 'FormatJavascript'
let s:tlist_def_javascript_settings = {
    \ 'lang': 'javascript', 'tags': {
      \ 'o': 'object',
      \ 'm': 'member',
      \ 'f': 'function',
    \ }
  \ }

" lisp language
let s:tlist_def_lisp_settings = {'lang': 'lisp', 'tags': {'f': 'function'}}

" lua language
let s:tlist_def_lua_settings = {'lang': 'lua', 'tags': {'f': 'function'}}

" makefiles
let s:tlist_def_make_settings = {'lang': 'make', 'tags': {'m': 'macro'}}

" pascal language
let s:tlist_def_pascal_settings = {
    \ 'lang': 'pascal', 'tags': {
      \ 'f': 'function',
      \ 'p': 'procedure'
    \ }
  \ }

" perl language
let s:tlist_def_perl_settings = {
    \ 'lang': 'perl', 'tags': {
      \ 'c': 'constant',
      \ 'l': 'label',
      \ 'p': 'package',
      \ 's': 'subroutine'
    \ }
  \ }

" php language
let s:tlist_format_php = 'FormatPhp'
let s:tlist_def_php_settings = {
    \ 'lang': 'php', 'tags': {
      \ 'c': 'class',
      \ 'd': 'constant',
      \ 'v': 'variable',
      \ 'f': 'function'
    \ }
  \ }

" python language
let s:tlist_format_python = 'FormatPython'
let s:tlist_def_python_settings = {
    \ 'lang': 'python', 'tags': {
      \ 'c': 'class',
      \ 'm': 'member',
      \ 'f': 'function'
    \ }
  \ }

" rexx language
let s:tlist_def_rexx_settings = {'lang': 'rexx', 'tags': {'s': 'subroutine'}}

" ruby language
let s:tlist_def_ruby_settings = {
    \ 'lang': 'ruby', 'tags': {
      \ 'c': 'class',
      \ 'f': 'method',
      \ 'F': 'function',
      \ 'm': 'singleton method'
    \ }
  \ }

" scheme language
let s:tlist_def_scheme_settings = {
    \ 'lang': 'scheme', 'tags': {
      \ 's': 'set',
      \ 'f': 'function'
    \ }
  \ }

" shell language
let s:tlist_def_sh_settings = {'lang': 'sh', 'tags': {'f': 'function'}}

" C shell language
let s:tlist_def_csh_settings = {'lang': 'sh', 'tags': {'f': 'function'}}

" Z shell language
let s:tlist_def_zsh_settings = {'lang': 'sh', 'tags': {'f': 'function'}}

" slang language
let s:tlist_def_slang_settings = {
    \ 'lang': 'slang', 'tags': {
      \ 'n': 'namespace',
      \ 'f': 'function'
    \ }
  \ }

" sml language
let s:tlist_def_sml_settings = {
    \ 'lang': 'sml', 'tags': {
      \ 'e': 'exception',
      \ 'c': 'functor',
      \ 's': 'signature',
      \ 'r': 'structure',
      \ 't': 'type',
      \ 'v': 'value',
      \ 'f': 'function'
    \ }
  \ }

" sql language
let s:tlist_def_sql_settings = {
    \ 'lang': 'sql', 'tags': {
      \ 'c': 'cursor',
      \ 'F': 'field',
      \ 'P': 'package',
      \ 'r': 'record',
      \ 's': 'subtype',
      \ 't': 'table',
      \ 'T': 'trigger',
      \ 'v': 'variable',
      \ 'f': 'function',
      \ 'p': 'procedure'
    \ }
  \ }

" tcl language
let s:tlist_def_tcl_settings = {
    \ 'lang': 'tcl', 'tags': {
      \ 'c': 'class',
      \ 'f': 'method',
      \ 'm': 'method',
      \ 'p': 'procedure'
    \ }
  \ }

" vera language
let s:tlist_def_vera_settings = {
    \ 'lang': 'vera', 'tags': {
      \ 'c': 'class',
      \ 'd': 'macro',
      \ 'e': 'enumerator',
      \ 'f': 'function',
      \ 'g': 'enum',
      \ 'm': 'member',
      \ 'p': 'program',
      \ 'P': 'prototype',
      \ 't': 'task',
      \ 'T': 'typedef',
      \ 'v': 'variable',
      \ 'x': 'externvar'
    \ }
  \ }

"verilog language
let s:tlist_def_verilog_settings = {
    \ 'lang': 'verilog', 'tags': {
      \ 'm': 'module',
      \ 'c': 'constant',
      \ 'P': 'parameter',
      \ 'e': 'event',
      \ 'r': 'register',
      \ 't': 'task',
      \ 'w': 'write',
      \ 'p': 'port',
      \ 'v': 'variable',
      \ 'f': 'function'
    \ }
  \ }

" vim language
let s:tlist_def_vim_settings = {
    \ 'lang': 'vim', 'tags': {
      \ 'a': 'autocmds',
      \ 'v': 'variable',
      \ 'f': 'function'
    \ }
  \ }

" yacc language
let s:tlist_def_yacc_settings = {'lang': 'yacc', 'tags': {'l': 'label'}}
" }}}

" AutoOpen() eclim/autoload/eclim/taglist/taglisttoo.vim {{{
function! s:AutoOpen()
  let open_window = 0

  let i = 1
  let buf_num = winbufnr(i)
  while buf_num != -1
    let filename = fnamemodify(bufname(buf_num), ':p')
    if !getbufvar(buf_num, '&diff') &&
     \ s:FileSupported(filename, getbufvar(buf_num, '&filetype'))
      let open_window = 1
      break
    endif
    let i = i + 1
    let buf_num = winbufnr(i)
  endwhile

  if open_window
    call s:TaglistToo()
  endif
endfunction " }}}

" Taglist([action]) eclim/autoload/eclim/taglist/taglisttoo.vim {{{
" action
"   - not supplied (or -1): toggle
"   - 1: open
"   - 0: close
function! s:Taglist(...)
  if !exists('g:Tlist_Ctags_Cmd')
    call EchoError('Unable to find a version of ctags installed.')
    return
  endif

  if bufname('%') == g:TagList_title
    call s:CloseTaglist()
    return
  endif

  let action = len(a:000) ? a:000[0] : -1

  if action == -1 || action == 0
    let winnum = bufwinnr(g:TagList_title)
    if winnum != -1
      let prevbuf = bufnr('%')
      exe winnum . 'wincmd w'
      call s:CloseTaglist()
      exec bufwinnr(prevbuf) . 'wincmd w'
      return
    endif
  endif

  if action == -1 || action == 1
    call s:ProcessTags(1)
    call s:StartAutocmds()

    augroup taglisttoo
      autocmd!
      autocmd BufUnload __Tag_List__ call s:Cleanup()
      autocmd CursorHold * call s:ShowCurrentTag()
    augroup END
  endif
endfunction " }}}

" Restore() eclim/autoload/eclim/taglist/taglisttoo.vim {{{
" Restore the taglist, typically after loading from a session file.
function! s:Restore()
  if exists('t:taglistoo_restoring')
    return
  endif
  let t:taglistoo_restoring = 1

  " prevent auto open from firing after session is loaded.
  augroup taglisttoo_autoopen
    autocmd!
  augroup END

  call DelayedCommand(
    \ 'let winnum = bufwinnr(g:TagList_title) | ' .
    \ 'if winnum != -1 | ' .
    \ '  exec "TlistToo" | ' .
    \ '  exec "TlistToo" | ' .
    \ '  unlet t:taglistoo_restoring | ' .
    \ 'endif')
endfunction " }}}

" s:StartAutocmds() eclim/autoload/eclim/taglist/taglisttoo.vim {{{
function! s:StartAutocmds()
  augroup taglisttoo_file
    autocmd!
    autocmd BufEnter *
      \ if bufwinnr(g:TagList_title) != -1 |
      \   call s:ProcessTags(0) |
      \ endif
    autocmd BufWritePost *
      \ if bufwinnr(g:TagList_title) != -1 |
      \   call s:ProcessTags(1) |
      \ endif
    " bit of a hack to re-process tags if the filetype changes after the tags
    " have been processed.
    autocmd FileType *
      \ if exists('b:ft') |
      \   if b:ft != &ft |
      \     if bufwinnr(g:TagList_title) != -1 |
      \       call s:ProcessTags(1) |
      \     endif |
      \   endif |
      \ else |
      \   let b:ft = &ft |
      \ endif
    autocmd WinLeave *
      \ if bufwinnr(g:TagList_title) != -1 |
      \   let s:taglisttoo_prevwinnr = winnr() |
      \ endif
  augroup END
endfunction " }}}

" s:StopAutocmds() eclim/autoload/eclim/taglist/taglisttoo.vim {{{
function! s:StopAutocmds()
  augroup taglisttoo_file
    autocmd!
  augroup END
endfunction " }}}

" s:CloseTaglist() eclim/autoload/eclim/taglist/taglisttoo.vim {{{
function! s:CloseTaglist()
  close
  call s:Cleanup()
endfunction " }}}

" s:Cleanup() eclim/autoload/eclim/taglist/taglisttoo.vim {{{
function! s:Cleanup()
  augroup taglisttoo_file
    autocmd!
  augroup END

  augroup taglisttoo
    autocmd!
  augroup END
endfunction " }}}

" s:ProcessTags(on_open_or_write) eclim/autoload/eclim/taglist/taglisttoo.vim {{{
function! s:ProcessTags(on_open_or_write)
  " on insert completion prevent vim's jumping back and forth from the
  " completion preview window from triggering a re-processing of tags
  if pumvisible()
    return
  endif

  " if we are entering a buffer whose taglist list is already loaded, then
  " don't do anything.
  if !a:on_open_or_write
    let bufnr = bufnr(g:TagList_title)
    let filebuf = getbufvar(bufnr, 'taglisttoo_file_bufnr')
    if filebuf == bufnr('%')
      return
    endif
  endif

  let filename = expand('%:p')
  if filename =~ s:taglisttoo_ignore || filename == ''
    return
  endif
  let filewin = winnr()

  let tags = []
  if s:FileSupported(expand('%:p'), &ft)
    if exists('g:tlist_{&ft}_settings')
      let settings = g:tlist_{&ft}_settings
      let types = join(keys(settings.tags), '')
    else
      let settings = s:tlist_def_{&ft}_settings
      let types = join(keys(settings.tags), '')
    endif

    let file = substitute(expand('%:p'), '\', '/', 'g')

    " support generated file contents (like viewing a .class file via jad)
    let tempfile = ''
    if !filereadable(file) || &buftype == 'nofile'
      let tempfile = g:EclimTempDir . '/' . fnamemodify(file, ':t')
      if tolower(file) != tolower(tempfile)
        let tempfile = escape(tempfile, ' ')
        exec 'write! ' . tempfile
        let file = tempfile
      endif
    endif

    try
      let command = g:Tlist_Ctags_Cmd_Ctags

      let command .= ' -f - --format=2 --excmd=pattern ' .
          \ '--fields=nks --sort=no --language-force=<lang> ' .
          \ '--<lang>-types=<types> "<file>"'
      let command = substitute(command, '<lang>', settings.lang, 'g')
      let command = substitute(command, '<types>', types, 'g')
      let command = substitute(command, '<file>', file, '')

      if (has('win32') || has('win64')) && command =~ '^"'
        let command .= ' "'
      endif

      let response = System(command)
    finally
      if tempfile != ''
        call delete(tempfile)
      endif
    endtry

    if v:shell_error
      call EchoError('taglist failed with error code: ' . v:shell_error)
      return
    endif

    let results = split(response, '\n')
    if len(response) == 1 && response[0] == '0'
      return
    endif

    while len(results) && results[0] =~ 'ctags.*: Warning:'
      call remove(results, 0)
    endwhile

    let truncated = 0
    if len(results)
      " for some reason, vim may truncate the output of system, leading to only
      " a partial taglist.
      let values = s:ParseOutputLine(results[-1])
      if len(values) < 5
        let truncated = 1
      endif

      for result in results
        let values = s:ParseOutputLine(result)

        " filter false positives found in comments.
        if values[-1] =~ 'line:[0-9]\+'
          exec 'let lnum = ' . substitute(values[-1], 'line:\([0-9]\+\).*', '\1', '')
          let line = getline(lnum)
          let col = len(line) - len(substitute(line, '^\s*', '', '')) + 1
          if synIDattr(synID(lnum, col, 1), "name") =~ '\([Cc]omment\|[Ss]tring\)'
            continue
          endif
        endif

        " exit if we run into apparent bug in vim that truncates the response
        " from system()
        if len(values) < 5
          break
        endif

        call add(tags, values)
      endfor
    endif

    if exists('s:tlist_format_{&ft}')
      exec 'call s:Window(settings.tags, tags, ' .
        \ s:tlist_format_{&ft} . '(settings.tags, tags))'
    else
      if g:Tlist_Sort_Type == 'name'
        call sort(tags)
      endif

      call s:Window(settings.tags, tags, s:FormatDefault(settings.tags, tags))
    endif

    " if vim truncated the output, then add a note in the taglist indicating
    " the the list has been truncated.
    if truncated
      setlocal modifiable
      call append(line('$'), '')
      call append(line('$'), 'Warning: taglist truncated.')
      setlocal nomodifiable
    endif

    " if the file buffer is no longer in the same window it was, then find its
    " new location. Occurs when taglist first opens.
    if winbufnr(filewin) != bufnr(filename)
      let filewin = bufwinnr(filename)
    endif

    if filewin != -1
      exec filewin . 'winc w'
    endif
  else
    " if the file isn't supported, then don't open the taglist window if it
    " isn't open already.
    let winnum = bufwinnr(g:TagList_title)
    if winnum != -1
      call s:Window({}, tags, [[],[]])
      winc p
    endif
  endif

  call s:ShowCurrentTag()
endfunction " }}}

" s:ParseOutputLine(line) eclim/autoload/eclim/taglist/taglisttoo.vim {{{
function! s:ParseOutputLine(line)
  let pre = substitute(a:line, '\(.\{-}\)\t\/\^.*', '\1', '')
  let pattern = substitute(a:line, '.\{-}\(\/\^.*\$\/;"\).*', '\1', '')
  let post = substitute(a:line, '.*\$\/;"\t', '', '')
  return split(pre, '\t') + [pattern] + split(post, '\t')
endfunction " }}}

" s:FormatDefault(types, tags) eclim/autoload/eclim/taglist/taglisttoo.vim {{{
" All format functions must return a two element list containing:
" result[0] - A list of length len(result[1]) where each value specifies the
"             tag index such that result[0][line('.') - 1] == tag index for
"             the current line.
"             For content lines that do no map to a tag, use -1 as the value.
" result[1] - A list of lines to be inserted as content into the taglist
"             window.
function! s:FormatDefault(types, tags)
  let lines = []
  let content = []

  call add(content, expand('%:t'))
  call add(lines, -1)

  for key in keys(a:types)
    let values = filter(copy(a:tags), 'len(v:val) > 3 && v:val[3] == key')
    call s:FormatType(a:tags, a:types[key], values, lines, content, "\t")
  endfor

  return [lines, content]
endfunction " }}}

" s:JumpToTag() eclim/autoload/eclim/taglist/taglisttoo.vim {{{
function! s:JumpToTag()
  if line('.') > len(b:taglisttoo_content[0])
    return
  endif

  let index = b:taglisttoo_content[0][line('.') - 1]
  if index == -1
    return
  endif

  let tag_info = b:taglisttoo_tags[index]

  call s:StopAutocmds()

  " handle case of buffer open in multiple windows.
  if s:taglisttoo_prevwinnr &&
   \ winbufnr(s:taglisttoo_prevwinnr) == b:taglisttoo_file_bufnr
    exec s:taglisttoo_prevwinnr . 'winc w'
  else
    exec bufwinnr(b:taglisttoo_file_bufnr) . 'winc w'
  endif

  call s:StartAutocmds()

  let lnum = s:GetTagLineNumber(tag_info)
  let pattern = s:GetTagPattern(tag_info)

  " account for my plugin which removes trailing spaces from the file
  let pattern = escape(pattern, '.~*[]')
  let pattern = substitute(pattern, '\s\+\$$', '\\s*$', '')

  if getline(lnum) =~ pattern
    mark '
    call cursor(lnum, 1)
    call s:ShowCurrentTag()
  else
    let pos = getpos('.')

    call cursor(lnum, 1)

    let up = search(pattern, 'bcnW')
    let down = search(pattern, 'cnW')

    " pattern found below recorded line
    if !up && down
      let line = down

    " pattern found above recorded line
    elseif !down && up
      let line = up

    " pattern found above and below recorded line
    elseif up && down
      " use the closest match to the recorded line
      if (lnum - up) < (down - lnum)
        let line = up
      else
        let line = down
      endif

    " pattern not found.
    else
      let line = 0
    endif

    call setpos('.', pos)
    if line
      mark '
      call cursor(line, 1)
      call s:ShowCurrentTag()
    endif
  endif
endfunction " }}}

" s:Window(types, tags, content) eclim/autoload/eclim/taglist/taglisttoo.vim {{{
function! s:Window(types, tags, content)
  let filename = expand('%:t')
  let file_bufnr = bufnr('%')

  let winnum = bufwinnr(g:TagList_title)
  if winnum != -1
    exe winnum . 'wincmd w'
  else
    call VerticalToolWindowOpen(g:TagList_title, 10)

    setlocal filetype=taglist
    setlocal buftype=nofile
    setlocal bufhidden=delete
    setlocal noswapfile
    setlocal nobuflisted
    setlocal nowrap
    setlocal tabstop=2

    syn match TagListFileName "^.*\%1l.*"
    hi link TagListFileName Identifier
    hi link TagListKeyword Statement
    hi TagListCurrentTag term=bold,underline cterm=bold,underline gui=bold,underline

    nnoremap <silent> <buffer> <cr> :call <SID>JumpToTag()<cr>
  endif

  let pos = [0, 1, 1, 0]
  " if we are updating the taglist for the same file, then preserve the
  " cursor position.
  if len(a:content[1]) > 0 && getline(1) == a:content[1][0]
    let pos = getpos('.')
  endif

  setlocal modifiable
  silent 1,$delete _
  call append(1, a:content[1])
  silent retab
  silent 1,1delete _
  setlocal nomodifiable

  call setpos('.', pos)

  " if the entire taglist can fit in the window, then reposition the content
  " just in case the previous contents result in the current contents being
  " scrolled up a bit.
  if len(a:content[1]) < winheight(winnr())
    normal! zb
  endif

  silent! syn clear TagListKeyword
  for value in values(a:types)
    exec 'syn keyword TagListKeyword ' . value
  endfor
  syn match TagListKeyword /^Warning:/

  let b:taglisttoo_content = a:content
  let b:taglisttoo_tags = a:tags
  let b:taglisttoo_file_bufnr = file_bufnr
endfunction " }}}

" s:ShowCurrentTag() eclim/autoload/eclim/taglist/taglisttoo.vim {{{
function! s:ShowCurrentTag()
  if s:FileSupported(expand('%:p'), &ft) && bufwinnr(g:TagList_title) != -1
    let tags = getbufvar(g:TagList_title, 'taglisttoo_tags')
    let content = getbufvar(g:TagList_title, 'taglisttoo_content')

    let clnum = line('.')
    let tlnum = 0
    let tindex = -1

    let index = 0
    for tag in tags
      let lnum = s:GetTagLineNumber(tag)
      let diff = clnum - lnum
      if diff >= 0 && (diff < (clnum - tlnum))
        let tlnum = lnum
        let current = tag
        let tindex = index
      endif
      let index += 1
    endfor

    if exists('current')
      let cwinnum = winnr()
      let twinnum = bufwinnr(g:TagList_title)

      call ExecWithoutAutocmds(twinnum . 'winc w')

      let index = index(content[0], tindex) + 1
      syn clear TagListCurrentTag
      exec 'syn match TagListCurrentTag "\S*\%' . index . 'l\S*"'
      if index != line('.')
        call cursor(index, 0)
        call winline()
      endif

      call ExecWithoutAutocmds(cwinnum . 'winc w')
    endif
  endif
endfunction " }}}

" s:FileSupported(filename, ftype) eclim/autoload/eclim/taglist/taglisttoo.vim {{{
" Check whether tag listing is supported for the specified file
function! s:FileSupported(filename, ftype)
  " Skip buffers with no names, buffers with filetype not set, and vimballs
  if a:filename == '' || a:ftype == '' || expand('%:e') == 'vba'
    return 0
  endif

  " Skip files which are not supported by exuberant ctags
  " First check whether default settings for this filetype are available.
  " If it is not available, then check whether user specified settings are
  " available. If both are not available, then don't list the tags for this
  " filetype
  let var = 's:tlist_def_' . a:ftype . '_settings'
  if !exists(var)
    let var = 'g:tlist_' . a:ftype . '_settings'
    if !exists(var)
      return 0
    endif
  endif

  " Skip files which are not readable or files which are not yet stored
  " to the disk
  if !filereadable(a:filename)
    return 0
  endif

  return 1
endfunction " }}}

" s:GetTagLineNumber(tag) eclim/autoload/eclim/taglist/taglisttoo.vim {{{
function! s:GetTagLineNumber(tag)
  if len(a:tag) > 4
    return substitute(a:tag[4], '.*:\(.*\)', '\1', '')
  endif
  return 0
endfunction " }}}


" FormatJava(types, tags) eclim/autoload/eclim/taglist/lang/java.vim {{{
function! FormatJava(types, tags)
  let lines = []
  let content = []

  call add(content, expand('%:t'))
  call add(lines, -1)

  let package = filter(copy(a:tags), 'v:val[3] == "p"')
  call s:FormatType(
      \ a:tags, a:types['p'], package, lines, content, "\t")

  let classes = filter(copy(a:tags), 'v:val[3] == "c"')

  " sort classes alphabetically except for the primary containing class.
  if len(classes) > 1 && g:Tlist_Sort_Type == 'name'
    let classes = [classes[0]] + sort(classes[1:])
  endif

  for class in classes
    call add(content, "")
    call add(lines, -1)
    let visibility = s:GetVisibility(class)
    call add(content, "\t" . visibility . a:types['c'] . ' ' . class[0])
    call add(lines, index(a:tags, class))

    let fields = filter(copy(a:tags),
      \ 'v:val[3] == "f" && len(v:val) > 5 && v:val[5] =~ "class:.*\\<" . class[0] . "$"')
    call s:FormatType(
        \ a:tags, a:types['f'], fields, lines, content, "\t\t")

    let methods = filter(copy(a:tags),
      \ 'v:val[3] == "m" && len(v:val) > 5 && v:val[5] =~ "class:.*\\<" . class[0] . "$"')
    call s:FormatType(
        \ a:tags, a:types['m'], methods, lines, content, "\t\t")
  endfor

  let interfaces = filter(copy(a:tags), 'v:val[3] == "i"')
  if g:Tlist_Sort_Type == 'name'
    call sort(interfaces)
  endif
  for interface in interfaces
    call add(content, "")
    call add(lines, -1)
    let visibility = s:GetVisibility(interface)
    call add(content, "\t" . visibility . a:types['i'] . ' ' . interface[0])
    call add(lines, index(a:tags, interface))

    let fields = filter(copy(a:tags),
      \ 'v:val[3] == "f" && len(v:val) > 5 && v:val[5] =~ "interface:.*\\<" . interface[0] . "$"')
    call s:FormatType(
        \ a:tags, a:types['f'], fields, lines, content, "\t\t")

    let methods = filter(copy(a:tags),
      \ 'v:val[3] == "m" && len(v:val) > 5 && v:val[5] =~ "interface:.*\\<" . interface[0] . "$"')
    call s:FormatType(
        \ a:tags, a:types['m'], methods, lines, content, "\t\t")
  endfor

  return [lines, content]
endfunction " }}}

" FormatJavascript(types, tags) eclim/autoload/eclim/taglist/lang/javascript.vim {{{
function! FormatJavascript(types, tags)
  let pos = getpos('.')

  let lines = []
  let content = []

  call add(content, expand('%:t'))
  call add(lines, -1)

  let object_contents = []

  let objects = filter(copy(a:tags), 'v:val[3] == "o"')
  let members = filter(copy(a:tags), 'v:val[3] == "m"')
  let functions = filter(copy(a:tags),
    \ 'v:val[3] == "f" && v:val[2] =~ "\\<function\\>"')
  let object_bounds = {}
  for object in objects
    exec 'let object_start = ' . split(object[4], ':')[1]
    call cursor(object_start, 1)
    while search('{', 'W') && s:SkipComments()
      " no op
    endwhile
    let object_end = searchpair('{', '', '}', 'W', 's:SkipComments()')

    let methods = []
    let indexes = []
    let index = 0
    for fct in members
      if len(fct) > 3
        exec 'let fct_line = ' . split(fct[4], ':')[1]
        if fct_line > object_start && fct_line < object_end
          call add(methods, fct)
        elseif fct_line > object_end
          break
        elseif fct_line < object_end
          call add(indexes, index)
        endif
      endif
      let index += 1
    endfor
    call reverse(indexes)
    for i in indexes
      call remove(members, i)
    endfor

    let indexes = []
    let index = 0
    for fct in functions
      if len(fct) > 3
        exec 'let fct_line = ' . split(fct[4], ':')[1]
        if fct_line > object_start && fct_line < object_end
          call add(methods, fct)
          call add(indexes, index)
        elseif fct_line == object_start
          call add(indexes, index)
        elseif fct_line > object_end
          break
        endif
      endif
      let index += 1
    endfor
    call reverse(indexes)
    for i in indexes
      call remove(functions, i)
    endfor

    if len(methods) > 0
      let parent_object = s:GetParentObject(
        \ object_contents, object_bounds, object_start, object_end)
      " remove methods from the parent if necessary
      if len(parent_object)
        call filter(parent_object.methods, 'index(methods, v:val) == -1')
      endif
      let object_bounds[string(object)] = [object_start, object_end]
      call add(object_contents, {'object': object, 'methods': methods})
    endif
  endfor

  if len(functions) > 0
    call add(content, "")
    call add(lines, -1)
    call s:FormatType(
        \ a:tags, a:types['f'], functions, lines, content, "\t")
  endif

  if g:Tlist_Sort_Type == 'name'
    call sort(object_contents, function('s:ObjectComparator'))
  endif

  for object_content in object_contents
    call add(content, "")
    call add(lines, -1)
    call add(content, "\t" . a:types['o'] . ' ' . object_content.object[0])
    call add(lines, index(a:tags, object_content.object))

    call s:FormatType(
        \ a:tags, a:types['f'], object_content.methods, lines, content, "\t\t")
  endfor

  call setpos('.', pos)

  return [lines, content]
endfunction " }}}

" s:ObjectComparator(o1, o2) eclim/autoload/eclim/taglist/lang/javascript.vim {{{
function s:ObjectComparator(o1, o2)
  let n1 = a:o1['object'][0]
  let n2 = a:o2['object'][0]
  return n1 == n2 ? 0 : n1 > n2 ? 1 : -1
endfunction " }}}

" s:SkipComments() eclim/autoload/eclim/taglist/lang/javascript.vim {{{
function s:SkipComments()
  let synname = synIDattr(synID(line('.'), col('.'), 1), "name")
  return synname =~ '\([Cc]omment\|[Ss]tring\)'
endfunction " }}}

" s:GetParentObject(objects, bounds, start, end) eclim/autoload/eclim/taglist/lang/javascript.vim {{{
function s:GetParentObject(objects, bounds, start, end)
  for key in keys(a:bounds)
    let range = a:bounds[key]
    if range[0] < a:start && range[1] > a:end
      for object_content in a:objects
        if string(object_content.object) == key
          return object_content
        endif
      endfor
      break
    endif
  endfor
  return {}
endfunction " }}}

" FormatType(tags, type, values, lines, content, indent) eclim/autoload/eclim/taglist/util.vim {{{
" tags: The list of tag results from eclim/ctags.
" type: The display name of the tag type we are formatting.
" values: List of tag results for the type.
" lines: The list representing the mapping of content entries to tag info.
" content: The list representing the display that we will add to.
" indent: The indentation to use on the display (string).
function! s:FormatType(tags, type, values, lines, content, indent)
  if len(a:values) > 0
    if g:Tlist_Sort_Type == 'name'
      call sort(a:values)
    endif

    call add(a:content, a:indent . a:type)
    call add(a:lines, -1)

    for value in a:values
      let visibility = s:GetVisibility(value)
      call add(a:content, "\t" . a:indent . visibility . value[0])
      call add(a:lines, index(a:tags, value))
    endfor
  endif
endfunction " }}}

" GetTagPattern(tag) eclim/autoload/eclim/taglist/util.vim {{{
function! s:GetTagPattern(tag)
  return strpart(a:tag[2], 1, len(a:tag[2]) - 4)
endfunction " }}}

" GetVisibility(tag) eclim/autoload/eclim/taglist/util.vim {{{
" Gets the visibility string for the supplied tag.
function! s:GetVisibility(tag)
  let pattern = s:GetTagPattern(a:tag)
  if pattern =~ '\<public\>'
    if pattern =~ '\<static\>'
      return '*'
    endif
    return '+'
  elseif pattern =~ '\<protected\>'
    return '#'
  elseif pattern =~ '\<private\>'
    return '-'
  endif
  return ''
endfunction " }}}

" FormatPhp(types, tags) eclim/autoload/eclim/taglist/lang/php.vim {{{
function! FormatPhp(types, tags)
  let pos = getpos('.')

  let lines = []
  let content = []

  call add(content, expand('%:t'))
  call add(lines, -1)

  let top_functions = filter(copy(a:tags), 'v:val[3] == "f"')

  let class_contents = []
  let classes = filter(copy(a:tags), 'v:val[3] == "c"')
  if g:Tlist_Sort_Type == 'name'
    call sort(classes)
  endif
  for class in classes
    exec 'let object_start = ' . split(class[4], ':')[1]
    call cursor(object_start, 1)
    call search('{', 'W')
    let object_end = searchpair('{', '', '}', 'W')

    let functions = []
    let indexes = []
    let index = 0
    for fct in top_functions
      if len(fct) > 3
        exec 'let fct_line = ' . split(fct[4], ':')[1]
        if fct_line > object_start && fct_line < object_end
          call add(functions, fct)
          call add(indexes, index)
        endif
      endif
      let index += 1
    endfor
    call reverse(indexes)
    for i in indexes
      call remove(top_functions, i)
    endfor

    call add(class_contents, {'class': class, 'functions': functions})
  endfor

  let interface_contents = []
  let interfaces = filter(copy(a:tags), 'v:val[3] == "i"')
  if g:Tlist_Sort_Type == 'name'
    call sort(interfaces)
  endif
  for interface in interfaces
    exec 'let object_start = ' . split(interface[4], ':')[1]
    call cursor(object_start, 1)
    call search('{', 'W')
    let object_end = searchpair('{', '', '}', 'W')

    let functions = []
    let indexes = []
    let index = 0
    for fct in top_functions
      if len(fct) > 3
        exec 'let fct_line = ' . split(fct[4], ':')[1]
        if fct_line > object_start && fct_line < object_end
          call add(functions, fct)
          call add(indexes, index)
        endif
      endif
      let index += 1
    endfor
    call reverse(indexes)
    for i in indexes
      call remove(top_functions, i)
    endfor

    call add(interface_contents, {'interface': interface, 'functions': functions})
  endfor

  if len(top_functions) > 0
    call add(content, "")
    call add(lines, -1)
    call s:FormatType(
        \ a:tags, a:types['f'], top_functions, lines, content, "\t")
  endif

  for class_content in class_contents
    call add(content, "")
    call add(lines, -1)
    call add(content, "\t" . a:types['c'] . ' ' . class_content.class[0])
    call add(lines, index(a:tags, class_content.class))

    call s:FormatType(
        \ a:tags, a:types['f'], class_content.functions, lines, content, "\t\t")
  endfor

  for interface_content in interface_contents
    call add(content, "")
    call add(lines, -1)
    call add(content, "\t" . a:types['i'] . ' ' . interface_content.interface[0])
    call add(lines, index(a:tags, interface_content.interface))

    call s:FormatType(
        \ a:tags, a:types['f'], interface_content.functions, lines, content, "\t\t")
  endfor

  call setpos('.', pos)

  return [lines, content]
endfunction " }}}

" FormatPython(types, tags) eclim/autoload/eclim/taglist/lang/python.vim {{{
function! FormatPython(types, tags)
  let lines = []
  let content = []

  call add(content, expand('%:t'))
  call add(lines, -1)

  let functions = filter(copy(a:tags), 'len(v:val) > 3 && v:val[3] == "f"')
  call s:FormatType(
      \ a:tags, a:types['f'], functions, lines, content, "\t")

  let classes = filter(copy(a:tags), 'len(v:val) > 3 && v:val[3] == "c"')
  if g:Tlist_Sort_Type == 'name'
    call sort(classes)
  endif

  for class in classes
    call add(content, "")
    call add(lines, -1)
    call add(content, "\t" . a:types['c'] . ' ' . class[0])
    call add(lines, index(a:tags, class))

    let members = filter(copy(a:tags),
        \ 'len(v:val) > 5 && v:val[3] == "m" && v:val[5] == "class:" . class[0]')
    call s:FormatType(
        \ a:tags, a:types['m'], members, lines, content, "\t\t")
  endfor

  return [lines, content]
endfunction " }}}


" GlobalVariables eclim/autoload/eclim/display/window.vim {{{
let g:VerticalToolBuffers = {}

if !exists('g:VerticalToolWindowSide')
  let g:VerticalToolWindowSide = 'left'
endif

if g:VerticalToolWindowSide == 'right'
  let g:VerticalToolWindowPosition = 'botright vertical'
else
  let g:VerticalToolWindowPosition = 'topleft vertical'
endif

if !exists('g:VerticalToolWindowWidth')
  let g:VerticalToolWindowWidth = 40
endif
" }}}

" VerticalToolWindowOpen(name, weight) eclim/autoload/eclim/display/window.vim {{{
" Handles opening windows in the vertical tool window on the left (taglist,
" project tree, etc.)
function! VerticalToolWindowOpen(name, weight)
  let taglist_window = exists('g:TagList_title') ? bufwinnr(g:TagList_title) : -1
  if exists('g:Tlist_Use_Horiz_Window') && g:Tlist_Use_Horiz_Window
    let taglist_window = -1
  endif

  let relative_window = 0
  let relative_window_loc = 'below'
  if taglist_window != -1 || len(g:VerticalToolBuffers) > 0
    if taglist_window != -1
      let relative_window = taglist_window
    endif
    for toolbuf in keys(g:VerticalToolBuffers)
      exec 'let toolbuf = ' . toolbuf
      if bufwinnr(toolbuf) != -1
        if relative_window == 0
          let relative_window = bufwinnr(toolbuf)
          if getbufvar(toolbuf, 'weight') > a:weight
            let relative_window_loc = 'below'
          else
            let relative_window_loc = 'above'
          endif
        elseif getbufvar(toolbuf, 'weight') > a:weight
          let relative_window = bufwinnr(toolbuf)
          let relative_window_loc = 'below'
        endif
      endif
    endfor
  endif

  if relative_window != 0
    let wincmd = relative_window . 'winc w | ' . relative_window_loc . ' '
  else
    let wincmd = g:VerticalToolWindowPosition . ' ' . g:VerticalToolWindowWidth
  endif

  let escaped = substitute(
    \ a:name, '\(.\{-}\)\[\(.\{-}\)\]\(.\{-}\)', '\1[[]\2[]]\3', 'g')
  let bufnum = bufnr(escaped)
  let name = bufnum == -1 ? a:name : '+buffer' . bufnum
  silent call ExecWithoutAutocmds(wincmd . ' split ' . name)

  setlocal winfixwidth
  setlocal nonumber

  let b:weight = a:weight
  let bufnum = bufnr('%')
  let g:VerticalToolBuffers[bufnum] = a:name
  augroup eclim_vertical_tool_windows
    autocmd!
    autocmd BufDelete * call s:PreventCloseOnBufferDelete()
    autocmd BufEnter * nested call s:CloseIfLastWindow()
  augroup END
  if exists('g:TagList_title') &&
   \ !exists('g:TagListToo') &&
   \ (!exists('g:Tlist_Use_Horiz_Window') || !g:Tlist_Use_Horiz_Window)
    augroup eclim_vertical_tool_windows_move
      autocmd!
    augroup END
    exec 'autocmd BufWinEnter ' . g:TagList_title .
      \ ' call s:MoveRelativeTo(g:TagList_title)'
  endif
  augroup eclim_vertical_tool_windows_buffer
    exec 'autocmd BufWinLeave <buffer> ' .
      \ 'silent! call remove(g:VerticalToolBuffers, ' . bufnum . ') | ' .
      \ 'autocmd! eclim_vertical_tool_windows_buffer * <buffer=' . bufnum . '>'
  augroup END
endfunction " }}}

" GetWindowOptions(winnum) eclim/autoload/eclim/display/window.vim {{{
" Gets a dictionary containing all the localy set options for the specified
" window.
function! GetWindowOptions(winnum)
  let curwin = winnr()
  try
    exec a:winnum . 'winc w'
    redir => list
    silent exec 'setlocal'
    redir END
  finally
    exec curwin . 'winc w'
  endtry

  let list = substitute(list, '---.\{-}---', '', '')
  let winopts = {}
  for wopt in split(list, '\_s\+')[1:]
    if wopt =~ '^[a-z]'
      if wopt =~ '='
        let key = substitute(wopt, '\(.\{-}\)=.*', '\1', '')
        let value = substitute(wopt, '.\{-}=\(.*\)', '\1', '')
        let winopts[key] = value
      else
        let winopts[wopt] = ''
      endif
    endif
  endfor
  return winopts
endfunction " }}}

" SetWindowOptions(winnum, options) eclim/autoload/eclim/display/window.vim {{{
" Given a dictionary of options, sets each as local options for the specified
" window.
function! SetWindowOptions(winnum, options)
  let curwin = winnr()
  try
    exec a:winnum . 'winc w'
    for key in keys(a:options)
      if key =~ '^no'
        silent! exec 'setlocal ' . key
      else
        silent! exec 'setlocal ' . key . '=' . a:options[key]
      endif
    endfor
  finally
    exec curwin . 'winc w'
  endtry
endfunction " }}}

" s:CloseIfLastWindow() eclim/autoload/eclim/display/window.vim {{{
function! s:CloseIfLastWindow()
  if histget(':', -1) !~ '^bd'
    let numtoolwindows = 0
    for toolbuf in keys(g:VerticalToolBuffers)
      exec 'let toolbuf = ' . toolbuf
      if bufwinnr(toolbuf) != -1
        let numtoolwindows += 1
      endif
    endfor
    if winnr('$') == numtoolwindows
      if tabpagenr('$') > 1
        tabclose
      else
        quitall
      endif
    endif
  endif
endfunction " }}}

" s:MoveRelativeTo(name) eclim/autoload/eclim/display/window.vim {{{
function! s:MoveRelativeTo(name)
  for toolbuf in keys(g:VerticalToolBuffers)
    exec 'let toolbuf = ' . toolbuf
    if bufwinnr(toolbuf) != -1
      call setwinvar(bufwinnr(toolbuf), 'marked_for_removal', 1)
      let winoptions = GetWindowOptions(bufwinnr(toolbuf))
      call remove(winoptions, 'filetype')
      call remove(winoptions, 'syntax')
      call VerticalToolWindowOpen(
        \ g:VerticalToolBuffers[toolbuf], getbufvar(toolbuf, 'weight'))
      call SetWindowOptions(winnr(), winoptions)
    endif
  endfor

  let winnum = 1
  while winnum <= winnr('$')
    if getwinvar(winnum, 'marked_for_removal') == 1
      exec winnum . 'winc w'
      close
    else
      let winnum += 1
    endif
  endwhile
  call VerticalToolWindowRestore()
endfunction " }}}

" s:PreventCloseOnBufferDelete() eclim/autoload/eclim/display/window.vim {{{
function! s:PreventCloseOnBufferDelete()
  let numtoolwindows = 0
  for toolbuf in keys(g:VerticalToolBuffers)
    exec 'let toolbuf = ' . toolbuf
    if bufwinnr(toolbuf) != -1
      let numtoolwindows += 1
    endif
  endfor

  let index = 1
  let numtempwindows = 0
  let tempbuffers = []
  while index <= winnr('$')
    let buf = winbufnr(index)
    if buf != -1 && getbufvar(buf, 'eclim_temp_window') != ''
      call add(tempbuffers, buf)
    endif
    let index += 1
  endwhile

  if winnr('$') == (numtoolwindows + len(tempbuffers))
    let toolbuf = bufnr('%')
    if g:VerticalToolWindowSide == 'right'
      vertical topleft new
    else
      vertical botright new
    endif
    setlocal noreadonly modifiable
    let winnum = winnr()
    exec 'let bufnr = ' . expand('<abuf>')

    redir => list
    silent exec 'buffers'
    redir END

    " build list of buffers open in other tabs to exclude
    let tabbuffers = []
    let lasttab = tabpagenr('$')
    let index = 1
    while index <= lasttab
      if index != tabpagenr()
        for bnum in tabpagebuflist(index)
          call add(tabbuffers, bnum)
        endfor
      endif
      let index += 1
    endwhile

    " build list of buffers not open in any window
    let buffers = []
    for entry in split(list, '\n')
      exec 'let bnum = ' . substitute(entry, '\s*\([0-9]\+\).*', '\1', '')
      if bnum != bufnr && index(tabbuffers, bnum) == -1 && bufwinnr(bnum) == -1
        if bnum < bufnr
          call insert(buffers, bnum)
        else
          call add(buffers, bnum)
        endif
      endif
    endfor

    " we found a hidden buffer, so open it
    if len(buffers) > 0
      exec 'buffer ' . buffers[0]
      doautocmd BufEnter
      doautocmd BufWinEnter
      doautocmd BufReadPost
    endif

    exec bufwinnr(toolbuf) . 'winc w'
    exec 'vertical resize ' . g:VerticalToolWindowWidth

    " fix the position of the temp windows
    if len(tempbuffers) > 0
      for buf in tempbuffers
        " open the buffer in the temp window position
        botright 10new
        exec 'buffer ' . buf
        setlocal winfixheight

        " close the old window
        let winnr = winnr()
        let index = 1
        while index <= winnr('$')
          if winbufnr(index) == buf && index != winnr
            exec index . 'winc w'
            close
            winc p
            break
          endif
          let index += 1
        endwhile
      endfor
    endif

    exec winnum . 'winc w'
  endif
endfunction " }}}


" End TagListToo: }}}


" vim:ft=vim:fdm=marker
