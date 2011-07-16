" ============================================================================
" File:        buffers.vim
" Description: vim plugin that provides buffers helpers. Almost all of parts
"              are taken from Eclim project <http://eclim.sourceforge.net>
" Maintainer:  Roman 'gryf' Dobosz <gryf73@gmail.com>
" Last Change: 2011-07-16
" License:     This program is free software: you can redistribute it and/or
"              modify it under the terms of the GNU General Public License as
"              published by the Free Software Foundation, either version 3 of
"              the License, or (at your option) any later version.
"
"              This program is distributed in the hope that it will be useful,
"              but WITHOUT ANY WARRANTY; without even the implied warranty of
"              MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
"              GNU General Public License for more details.
"
"              You should have received a copy of the GNU General Public
"              License along with this program.  If not, see
"              <http://www.gnu.org/licenses/>.
" ============================================================================
let s:Eclim_ver = '1.7.1'

" Eclim: {{{1
" files:
" - plugin/eclim.vim (global vars)
" - plugin/common.vim (commands)

" Global Variables {{{2

if has("signs")
  if !exists("g:EclimSignLevel")
    let g:EclimSignLevel = 5
  endif
else
  let g:EclimSignLevel = 0
endif

if !exists("g:EclimInfoHighlight")
    let g:EclimInfoHighlight = "Statement"
endif

if !exists("g:EclimLogLevel")
  let g:EclimLogLevel = 4
endif

if !exists("g:EclimTraceHighlight")
  let g:EclimTraceHighlight = "Normal"
endif
if !exists("g:EclimDebugHighlight")
  let g:EclimDebugHighlight = "Normal"
endif
if !exists("g:EclimInfoHighlight")
  let g:EclimInfoHighlight = "Statement"
endif
if !exists("g:EclimWarningHighlight")
  let g:EclimWarningHighlight = "WarningMsg"
endif
if !exists("g:EclimErrorHighlight")
  let g:EclimErrorHighlight = "Error"
endif
if !exists("g:EclimFatalHighlight")
  let g:EclimFatalHighlight = "Error"
endif

if !exists("g:EclimShowCurrentError")
  let g:EclimShowCurrentError = 1
endif

if !exists("g:EclimShowCurrentErrorBalloon")
  let g:EclimShowCurrentErrorBalloon = 1
endif

if !exists("g:EclimOpenQFLists")
  let g:EclimOpenQFLists = 1
endif

" }}}

" Command Declarations {{{2

if !exists(":Buffers")
  command Buffers :call s:Buffers()
endif

" }}}

" End Eclim: }}}

" Common Buffers: {{{1

" Global Variables {{{2
if !exists('g:EclimBuffersSort')
  let g:EclimBuffersSort = 'file'
endif
if !exists('g:EclimBuffersSortDirection')
  let g:EclimBuffersSortDirection = 'asc'
endif
if !exists('g:EclimBuffersDefaultAction')
  let g:EclimBuffersDefaultAction = 'edit'
endif
" }}}

" Buffers() eclim/autoload/eclim/common/buffers.vim {{{2
" Like, :buffers, but opens a temporary buffer.
function! s:Buffers()
  redir => list
  silent exec 'buffers'
  redir END

  let buffers = []
  let filelength = 0
  for entry in split(list, '\n')
    let buffer = {}
    let buffer.status = substitute(entry, '\s*[0-9]\+\s\+\(.\{-}\)\s\+".*', '\1', '')
    let buffer.path = substitute(entry, '.\{-}"\(.\{-}\)".*', '\1', '')
    let buffer.path = fnamemodify(buffer.path, ':p')
    let buffer.file = fnamemodify(buffer.path, ':p:t')
    let buffer.dir = fnamemodify(buffer.path, ':p:h')
    exec 'let buffer.bufnr = ' . substitute(entry, '\s*\([0-9]\+\).*', '\1', '')
    exec 'let buffer.lnum = ' .
      \ substitute(entry, '.*"\s\+line\s\+\([0-9]\+\).*', '\1', '')
    call add(buffers, buffer)

    if len(buffer.file) > filelength
      let filelength = len(buffer.file)
    endif
  endfor

  if g:EclimBuffersSort != ''
    call sort(buffers, 'BufferCompare')
  endif

  let lines = []
  for buffer in buffers
    call add(lines, s:BufferEntryToLine(buffer, filelength))
  endfor

  call TempWindow('[buffers]', lines)

  setlocal modifiable noreadonly
  call append(line('$'), ['', '" use ? to view help'])
  setlocal nomodifiable readonly

  let b:eclim_buffers = buffers

  " syntax
  set ft=eclim_buffers
  hi link BufferActive Special
  hi link BufferHidden Comment
  syntax match BufferActive /+\?active\s\+\(\[RO\]\)\?/
  syntax match BufferHidden /+\?hidden\s\+\(\[RO\]\)\?/
  syntax match Comment /^".*/

  " mappings
  nnoremap <silent> <buffer> <cr> :call <SID>BufferOpen2(g:EclimBuffersDefaultAction)<cr>
  nnoremap <silent> <buffer> E :call <SID>BufferOpen2('edit')<cr>
  nnoremap <silent> <buffer> S :call <SID>BufferOpen2('split')<cr>
  nnoremap <silent> <buffer> T :call <SID>BufferOpen('tablast \| tabnew')<cr>
  nnoremap <silent> <buffer> D :call <SID>BufferDelete()<cr>
  nnoremap <silent> <buffer> R :Buffers<cr>

  " assign to buffer var to get around weird vim issue passing list containing
  " a string w/ a '<' in it on execution of mapping.
  let b:buffers_help = [
      \ '<cr> - open buffer with default action',
      \ 'E - open with :edit',
      \ 'S - open in a new split window',
      \ 'T - open in a new tab',
      \ 'D - delete the buffer',
      \ 'R - refresh the buffer list',
    \ ]
  nnoremap <buffer> <silent> ?
    \ :call BufferHelp(b:buffers_help, 'vertical', 40)<cr>

  "augroup eclim_buffers
  "  autocmd!
  "  autocmd BufAdd,BufWinEnter,BufDelete,BufWinLeave *
  "    \ call eclim#common#buffers#BuffersUpdate()
  "  autocmd BufUnload <buffer> autocmd! eclim_buffers
  "augroup END
endfunction " }}}

" BufferCompare(buffer1, buffer2) eclim/autoload/eclim/common/buffers.vim {{{2
function! BufferCompare(buffer1, buffer2)
  exec 'let attr1 = a:buffer1.' . g:EclimBuffersSort
  exec 'let attr2 = a:buffer2.' . g:EclimBuffersSort
  let compare = attr1 == attr2 ? 0 : attr1 > attr2 ? 1 : -1
  if g:EclimBuffersSortDirection == 'desc'
    let compare = 0 - compare
  endif
  return compare
endfunction " }}}

" s:BufferDelete() {{{2
function! s:BufferDelete()
  let line = line('.')
  if line > len(b:eclim_buffers)
    return
  endif

  let index = line - 1
  setlocal modifiable
  setlocal noreadonly
  exec line . ',' . line . 'delete _'
  setlocal nomodifiable
  setlocal readonly
  let buffer = b:eclim_buffers[index]
  call remove(b:eclim_buffers, index)

  let winnr = bufwinnr(buffer.bufnr)
  if winnr != -1
    " if active in a window, go to the window to delete the buffer since that
    " keeps eclim's prevention of closing the last non-utility window working
    " properly.
    let curwin = winnr()
    exec winnr . 'winc w'
    bdelete
    exec curwin . 'winc w'
  else
    exec 'bd ' . buffer.bufnr
  endif
endfunction " }}}

" s:BufferEntryToLine(buffer, filelength) eclim/autoload/eclim/common/buffers.vim {{{2
function! s:BufferEntryToLine(buffer, filelength)
  let line = ''
  let line .= a:buffer.status =~ '+' ? '+' : ' '
  let line .= a:buffer.status =~ 'a' ? 'active' : 'hidden'
  let line .= a:buffer.status =~ '[-=]' ? ' [RO] ' : '      '
  let line .= a:buffer.file

  let pad = a:filelength - len(a:buffer.file) + 2
  while pad > 0
    let line .= ' '
    let pad -= 1
  endwhile

  let line .= a:buffer.dir
  return line
endfunction " }}}

" s:BufferOpen(cmd) eclim/autoload/eclim/common/buffers.vim {{{2
function! s:BufferOpen(cmd)
  let line = line('.')
  if line > len(b:eclim_buffers)
    return
  endif

  let file = bufname(b:eclim_buffers[line - 1].bufnr)
  let winnr = b:winnr
  close
  exec winnr . 'winc w'
  call GoToBufferWindowOrOpen(file, a:cmd)
endfunction " }}}

" End Common Buffers: }}}

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

" GoToBufferWindow(buf) eclim/autoload/eclim/util.vim {{{2
" Focuses the window containing the supplied buffer name or buffer number.
" Returns 1 if the window was found, 0 otherwise.
function! GoToBufferWindow(buf)
  if type(a:buf) == 0
    let winnr = bufwinnr(a:buf)
  else
    let name = EscapeBufferName(a:buf)
    let winnr = bufwinnr(bufnr('^' . name . '$'))
  endif
  if winnr != -1
    exec winnr . "winc w"
    call DelayedCommand('doautocmd WinEnter')
    return 1
  endif
  return 0
endfunction " }}}

" GoToBufferWindowOrOpen(name, cmd) eclim/autoload/eclim/util.vim {{{2
" Gives focus to the window containing the buffer for the supplied file, or if
" none, opens the file using the supplied command.
function! GoToBufferWindowOrOpen(name, cmd)
  let name = EscapeBufferName(a:name)
  let winnr = bufwinnr(bufnr('^' . name))
  if winnr != -1
    exec winnr . "winc w"
    call DelayedCommand('doautocmd WinEnter')
  else
    let cmd = a:cmd
    " if splitting and the buffer is a unamed empty buffer, then switch to an
    " edit.
    if cmd == 'split' && expand('%') == '' &&
     \ !&modified && line('$') == 1 && getline(1) == ''
      let cmd = 'edit'
    endif
    silent exec cmd . ' ' . escape(Simplify(a:name), ' ')
  endif
endfunction " }}}


" GoToBufferWindowRegister(buf) eclim/autoload/eclim/util.vim {{{2
" Registers the autocmd for returning the user to the supplied buffer when the
" current buffer is closed.
function! GoToBufferWindowRegister(buf)
  exec 'autocmd BufWinLeave <buffer> ' .
    \ 'call GoToBufferWindow("' . escape(a:buf, '\') . '") | ' .
    \ 'doautocmd BufEnter'
endfunction " }}}

" Simplify(file) eclim/autoload/eclim/util.vim {{{2
" Simply the supplied file to the shortest valid name.
function! Simplify(file)
  let file = a:file

  " Don't run simplify on url files, it will screw them up.
  if file !~ '://'
    let file = simplify(file)
  endif

  " replace all '\' chars with '/' except those escaping spaces.
  let file = substitute(file, '\\\([^[:space:]]\)', '/\1', 'g')
  let cwd = substitute(getcwd(), '\', '/', 'g')
  if cwd !~ '/$'
    let cwd .= '/'
  endif

  if file =~ '^' . cwd
    let file = substitute(file, '^' . cwd, '', '')
  endif

  return file
endfunction " }}}

" TempWindow(name, lines, [readonly]) eclim/autoload/eclim/util.vim {{{2
" Opens a temp window w/ the given name and contents which is readonly unless
" specified otherwise.
function! TempWindow(name, lines, ...)
  let filename = expand('%:p')
  let winnr = winnr()

  call TempWindowClear(a:name)
  let name = EscapeBufferName(a:name)

  if bufwinnr(name) == -1
    silent! noautocmd exec "botright 10sview " . escape(a:name, ' []')
    setlocal nowrap
    setlocal winfixheight
    setlocal noswapfile
    setlocal nobuflisted
    setlocal buftype=nofile
    setlocal bufhidden=delete
    silent doautocmd WinEnter
  else
    let temp_winnr = bufwinnr(name)
    if temp_winnr != winnr()
      exec temp_winnr . 'winc w'
      silent doautocmd WinEnter
    endif
  endif

  setlocal modifiable
  setlocal noreadonly
  call append(1, a:lines)
  retab
  silent 1,1delete _

  if len(a:000) == 0 || a:000[0]
    setlocal nomodified
    setlocal nomodifiable
    setlocal readonly
  endif

  silent doautocmd BufEnter

  " Store filename and window number so that plugins can use it if necessary.
  if filename != expand('%:p')
    let b:filename = filename
    let b:winnr = winnr

    augroup eclim_temp_window
      autocmd! BufWinLeave <buffer>
      call GoToBufferWindowRegister(b:filename)
    augroup END
  endif
endfunction " }}}

" TempWindowClear(name) eclim/autoload/eclim/util.vim {{{2
" Clears the contents of the temp window with the given name.
function! TempWindowClear(name)
  let name = EscapeBufferName(a:name)
  if bufwinnr(name) != -1
    let curwinnr = winnr()
    exec bufwinnr(name) . "winc w"
    setlocal modifiable
    setlocal noreadonly
    silent 1,$delete _
    exec curwinnr . "winc w"
  endif
endfunction " }}}

" End Util: }}}

" Eclim Help: {{{1

" BufferHelp(lines, orientation, size) eclim/autoload/eclim/help.vim {{{
" Function to display a help window for the current buffer.
function! BufferHelp(lines, orientation, size)
  let orig_bufnr = bufnr('%')
  let name = expand('%')
  if name =~ '^\W.*\W$'
    let name = name[:-2] . ' Help' . name[len(name) - 1]
  else
    let name .= ' Help'
  endif

  let bname = EscapeBufferName(name)

  let orient = a:orientation == 'vertical' ? 'v' : ''
  if bufwinnr(bname) != -1
    exec 'bd ' . bufnr(bname)
    return
  endif

  silent! noautocmd exec a:size . orient . "new " . escape(name, ' ')
  if a:orientation == 'vertical'
    setlocal winfixwidth
  else
    setlocal winfixheight
  endif
  setlocal nowrap
  setlocal noswapfile nobuflisted nonumber
  setlocal buftype=nofile bufhidden=delete
  nnoremap <buffer> <silent> ? :bd<cr>
  nnoremap <buffer> <silent> q :bd<cr>

  setlocal modifiable noreadonly
  silent 1,$delete _
  call append(1, a:lines)
  retab
  silent 1,1delete _

  if len(a:000) == 0 || a:000[0]
    setlocal nomodified nomodifiable readonly
  endif

  let help_bufnr = bufnr('%')
  augroup eclim_help_buffer
    autocmd! BufWinLeave <buffer>
    autocmd BufWinLeave <buffer> nested autocmd! eclim_help_buffer * <buffer>
    exec 'autocmd BufWinLeave <buffer> nested ' .
      \ 'autocmd! eclim_help_buffer * <buffer=' . orig_bufnr . '>'
    exec 'autocmd! BufWinLeave <buffer=' . orig_bufnr . '>'
    exec 'autocmd BufWinLeave <buffer=' . orig_bufnr . '> nested bd ' . help_bufnr
  augroup END

  return help_bufnr
endfunction " }}}

" }}}

" Gryfs Mods: {{{

" s:BufferOpen2(cmd) (gryf) {{{2
function! s:BufferOpen2(cmd)
  let line = line('.')
  if line > len(b:eclim_buffers)
    return
  endif

  let bufnr = b:eclim_buffers[line - 1].bufnr
  let winnr = b:winnr
  close
  exec winnr . 'winc w'
  call s:GoToBufferWindowOrOpen2(bufnr, a:cmd)
endfunction " }}}

" GoToBufferWindowOrOpen2(nr, cmd) (gryf) {{{2
" modified function GoToBufferWindowOrOpen. instead of buffer name it accepts
" buffer number.
function! s:GoToBufferWindowOrOpen2(nr, cmd)
  let winnr = bufwinnr(a:nr)
  if winnr != -1
    exec winnr . "winc w"
    call DelayedCommand('doautocmd WinEnter')
  else
    if a:cmd == 'edit'
      silent exec 'buffer ' . a:nr
    elseif a:cmd == 'split'
      silent exec 'sbuffer ' . a:nr
    endif
  endif
endfunction " }}}

" End Gryfs Mods: }}}

" vim:ft=vim:fdm=marker

