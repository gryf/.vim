" ============================================================================
" File:        eclim_py.vim
" Description: vim plugin that provides some python helpers. Most of parts are
"              taken from Eclim project <http://eclim.sourceforge.net>
" Maintainer:  Roman 'gryf' Dobosz <gryf73@gmail.com>
" Last Change: 2010-02-10
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
let s:Eclim_ver = '1.5.4'

" Further Description: {{{1
"   @gryf: Python and editor helpers taken over from Eclim project. There are
"   couple of nice tools, which I want to have separately from Eclim project.
"   Just for my conviniece and because I mainly work with Python files, I'll
"   put all of necessary thing into this one file. 
"
"   Added:
"       :Buffers
"       :Sign
"       :Signs
"       :PyLint
"       :Validate (pyflakes)
"       :QuickFixClear
"       :LocationListClear
"   TODO:
"       :Validate (rope) [this one is not crucial. at least for now.]
"       :SignClearUser
"       :SignClearAll
"       (w daleszej kolejności)
"       :PythonRegex
"       :LocateFile (do silnego przerobienia)
"
" }}}

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
  command Buffers :call Buffers()
endif

if has('signs')
  if !exists(":Sign")
    command Sign :call SignsToggle('user', line('.'))
  endif
  if !exists(":Signs")
    command Signs :call SignsViewSigns('user')
  endif
  if !exists(":SignClearUser")
    command SignClearUser :call SignsUnplaceAll(SignsGetExisting('user'))
  endif
  if !exists(":SignClearAll")
    command SignClearAll :call SignsUnplaceAll(SignsGetExisting())
  endif
endif

if !exists(":QuickFixClear")
  command QuickFixClear :call setqflist([]) | call SignsUpdate()
endif
if !exists(":LocationListClear")
  command LocationListClear :call setloclist(0, []) | call SignsUpdate()
endif

" }}}

" Auto Commands{{{2

if g:EclimSignLevel
  augroup eclim_qf
    autocmd QuickFixCmdPost *make* call SignsShow('', 'qf')
    autocmd QuickFixCmdPost grep*,vimgrep* call SignsShow('i', 'qf')
    autocmd QuickFixCmdPost lgrep*,lvimgrep* call SignsShow('i', 'loc')
    autocmd BufWinEnter * call SignsUpdate()
  augroup END
endif

if g:EclimShowCurrentError
  augroup eclim_show_error
    autocmd!
    autocmd CursorMoved * call ShowCurrentError()
  augroup END
endif

if g:EclimShowCurrentErrorBalloon && has('balloon_eval')
  set ballooneval
  set balloonexpr=Balloon(GetLineError(line('.')))
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
if !exists('g:EclimOnlyExclude')
  let g:EclimOnlyExclude =
    \ '\(NERD_tree_*\|__Tag_List__\|command-line\)'
endif
" }}}

" Buffers() eclim/autoload/eclim/common/buffers.vim {{{2
" Like, :buffers, but opens a temporary buffer.
function! Buffers()
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
  let b:eclim_buffers = buffers

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

  " assign to buffer var to get around weird vim issue passing list containing
  " a string w/ a '<' in it on execution of mapping.
  let b:buffers_help = [
      \ '<cr> - open buffer with default action',
      \ 'E - open with :edit',
      \ 'S - open in a new split window',
      \ 'T - open in a new tab',
      \ 'D - delete the buffer',
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
  exec 'bd ' . b:eclim_buffers[index].bufnr
  setlocal modifiable
  setlocal noreadonly
  exec line . ',' . line . 'delete _'
  setlocal nomodifiable
  setlocal readonly
  call remove(b:eclim_buffers, index)
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

" Balloon(message) eclim/autoload/eclim/util.vim {{{2
" Function for use as a vim balloonexpr expression.
function! Balloon(message)
  let message = a:message
  if !has('balloon_multiline')
    " remove any new lines
    let message = substitute(message, '\n', ' ', 'g')
  endif
  return message
endfunction " }}}

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

" EchoTrace(message) eclim/autoload/eclim/util.vim {{{2
function! EchoTrace(message)
  call s:EchoLevel(a:message, 6, g:EclimTraceHighlight)
endfunction " }}}

" EchoWarning(message) eclim/autoload/eclim/util.vim {{{2
function! EchoWarning(message)
  call s:EchoLevel(a:message, 3, g:EclimWarningHighlight)
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

" Echo(message) eclim/autoload/eclim/util.vim {{{2
" Echos a message using the info highlight regardless of what log level is set.
function! Echo(message)
  if a:message != "0" && g:EclimLogLevel > 0
    exec "echohl " . g:EclimInfoHighlight
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
  let name = escape(a:name, ' ')
  return substitute(name, '\(.\{-}\)\[\(.\{-}\)\]\(.\{-}\)', '\1[[]\2[]]\3', 'g')
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
    silent exec a:cmd . ' ' . escape(Simplify(a:name), ' ')
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

" SetLocationList(list, [action]) eclim/autoload/eclim/util.vim {{{2
" Sets the contents of the location list for the current window.
function! SetLocationList(list, ...)
  let loclist = a:list

  " filter the list if the current buffer defines a list of filters.
  if exists('b:EclimLocationListFilter')
    let newlist = []
    for item in loclist
      let addit = 1

      for filter in b:EclimLocationListFilter
        if item.text =~ filter
          let addit = 0
          break
        endif
      endfor

      if addit
        call add(newlist, item)
      endif
    endfor
    let loclist = newlist
  endif

  if a:0 == 0
    call setloclist(0, loclist)
  else
    call setloclist(0, loclist, a:1)
  endif
  if g:EclimShowCurrentError && len(loclist) > 0
    call DelayedCommand('call ShowCurrentError()')
  endif
  call SignsUpdate()
endfunction " }}}

" ClearLocationList([namespace, namespace, ...]) eclim/autoload/eclim/util.vim {{{2
" Clears the current location list.  Optionally 'namespace' arguments can be
" supplied which will only clear items with text prefixed with '[namespace]'.
" Also the special namespace 'global' may be supplied which will only remove
" items with no namepace prefix.
function! ClearLocationList(...)
  if a:0 > 0
    let loclist = getloclist(0)
    if len(loclist) > 0
      let pattern = ''
      for ns in a:000
        if pattern != ''
          let pattern .= '\|'
        endif
        if ns == 'global'
          let pattern .= '\(\[\w\+\]\)\@!'
        else
          let pattern .= '\[' . ns . '\]'
        endif
      endfor
      let pattern = '^\(' . pattern . '\)'

      call filter(loclist, 'v:val.text !~ pattern')
      call setloclist(0, loclist, 'r')
    endif
  else
    call setloclist(0, [], 'r')
  endif
  call SignsUpdate()
endfunction " }}}

" SetQuickfixList(list, [action]) eclim/autoload/eclim/util.vim {{{2
" Sets the contents of the quickfix list.
function! SetQuickfixList(list, ...)
  let qflist = a:list
  if exists('b:EclimQuickfixFilter')
    let newlist = []
    for item in qflist
      let addit = 1

      for filter in b:EclimQuickfixFilter
        if item.text =~ filter
          let addit = 0
          break
        endif
      endfor

      if addit
        call add(newlist, item)
      endif
    endfor
    let qflist = newlist
  endif
  if a:0 == 0
    call setqflist(qflist)
  else
    call setqflist(qflist, a:1)
  endif
  if g:EclimShowCurrentError && len(qflist) > 0
    call DelayedCommand('call ShowCurrentError()')
  endif
  call SignsUpdate()
endfunction " }}}

" ShowCurrentError() eclim/autoload/eclim/util.vim {{{2
" Shows the error on the cursor line if one.
function! ShowCurrentError()
  let message = GetLineError(line('.'))
  if message != ''
    " remove any new lines
    let message = substitute(message, '\n', ' ', 'g')

    if len(message) > (&columns - 1)
      let message = strpart(message, 0, &columns - 4) . '...'
    endif

    call WideMessage('echo', message)
    let s:show_current_error_displaying = 1
  else
    " clear the message if one of our error messages was displaying
    if s:show_current_error_displaying
      call WideMessage('echo', message)
      let s:show_current_error_displaying = 0
    endif
  endif
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
    call EchoTrace('exec: ' . a:cmd)
    exec a:cmd
  else
    call EchoTrace('system: ' . a:cmd)
    let result = system(a:cmd)
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

" TempWindow(name, lines, [readonly]) eclim/autoload/eclim/util.vim {{{2
" Opens a temp window w/ the given name and contents which is readonly unless
" specified otherwise.
function! TempWindow(name, lines, ...)
  let filename = expand('%:p')
  let winnr = winnr()

  call TempWindowClear(a:name)
  let name = EscapeBufferName(a:name)

  if bufwinnr(name) == -1
    silent! noautocmd exec "botright 10sview " . escape(a:name, ' ')
    let b:eclim_temp_window = 1

    " play nice with maximize.vim
    "if eclim#display#maximize#GetMaximizedWindow()
    "  call eclim#display#maximize#AdjustFixedWindow(10, 1)
    "endif

    setlocal nowrap
    setlocal winfixheight
    setlocal noswapfile
    setlocal nobuflisted
    setlocal buftype=nofile
    setlocal bufhidden=delete
  else
    exec bufwinnr(name) . "winc w"
  endif

  set modifiable
  set noreadonly
  call append(1, a:lines)
  retab
  silent 1,1delete _

  if len(a:000) == 0 || a:000[0]
    setlocal nomodified
    setlocal nomodifiable
    setlocal readonly
  endif

  doautocmd BufEnter

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

" WideMessage(command, message) eclim/autoload/eclim/util.vim {{{2
" Executes the supplied echo command and forces vim to display as much as
" possible without the "Press Enter" prompt.
" Thanks to vimtip #1289
function! WideMessage(command, message)
  let saved_ruler = &ruler
  let saved_showcmd = &showcmd

  let message = substitute(a:message, '^\s\+', '', '')

  set noruler noshowcmd
  redraw
  exec a:command . ' "' . escape(message, '"\') . '"'

  let &ruler = saved_ruler
  let &showcmd = saved_showcmd
endfunction " }}}

" WillWrittenBufferClose() eclim/autoload/eclim/util.vim {{{2
" Returns 1 if the current buffer is to be hidden/closed/deleted after it is
" written, or 0 otherwise.  This function is useful during a post write auto
" command for determining whether or not to perform some operation based on
" whether the buffer will still be visible to the user once the current
" command has finished.
" Note: This function only detects command typed by the user at the
" command (:) prompt, not any normal mappings which may hide/close/delete the
" buffer.
function! WillWrittenBufferClose()
  return histget("cmd") =~ s:buffer_write_closing_commands
endfunction " }}}

" End Util: }}}

" Display Signs: {{{1

" Global Variables eclim/autoload/eclim/display/signs.vim {{{2
if !exists("g:EclimShowQuickfixSigns")
  let g:EclimShowQuickfixSigns = 1
endif

if !exists("g:EclimUserSignText")
  let g:EclimUserSignText = '#'
endif

if !exists("g:EclimUserSignHighlight")
  let g:EclimUserSignHighlight = g:EclimInfoHighlight
endif
" }}}

" Define(name, text, highlight) eclim/autoload/eclim/display/signs.vim {{{2
" Defines a new sign name or updates an existing one.
function! SignsDefine(name, text, highlight)
  exec "sign define " . a:name . " text=" . a:text . " texthl=" . a:highlight
endfunction " }}}

" Place(name, line) eclim/autoload/eclim/display/signs.vim {{{2
" Places a sign in the current buffer.
function! SignsPlace(name, line)
  if a:line > 0
    let lastline = line('$')
    let line = a:line <= lastline ? a:line : lastline
    exec "sign place " . line . " line=" . line . " name=" . a:name .
      \ " buffer=" . bufnr('%')
  endif
endfunction " }}}

" PlaceAll(name, list) eclim/autoload/eclim/display/signs.vim {{{2
" Places a sign in the current buffer for each line in the list.
function! SignsPlaceAll(name, list)
  let lastline = line('$')
  for line in a:list
    if line > 0
      let line = line <= lastline ? line : lastline
      exec "sign place " . line . " line=" . line . " name=" . a:name .
        \ " buffer=" . bufnr('%')
    endif
  endfor
endfunction " }}}

" Unplace(id) eclim/autoload/eclim/display/signs.vim {{{2
" Un-places a sign in the current buffer.
function! SignsUnplace(id)
  exec 'sign unplace ' . a:id . ' buffer=' . bufnr('%')
endfunction " }}}

" Toggle(name, line) eclim/autoload/eclim/display/signs.vim {{{2
" Toggle a sign on the current line.
function! SignsToggle(name, line)
  if a:line > 0
    let existing = SignsGetExisting(a:name)
    let exists = len(filter(existing, "v:val['line'] == a:line"))
    if exists
      call SignsUnplace(a:line)
    else
      call SignsPlace(a:name, a:line)
    endif
  endif
endfunction " }}}

" CompareSigns(s1, s2) eclim/autoload/eclim/display/signs.vim {{{2
" Used by ViewSigns to sort list of sign dictionaries.
function! s:CompareSigns(s1, s2)
  if a:s1.line == a:s2.line
    return 0
  endif
  if a:s1.line > a:s2.line
    return 1
  endif
  return -1
endfunction " }}}

" ViewSigns(name) eclim/autoload/eclim/display/signs.vim {{{2
" Open a window to view all placed signs with the given name in the current
" buffer.
function! SignsViewSigns(name)
  let filename = expand('%:p')
  let signs = SignsGetExisting(a:name)
  call sort(signs, 's:CompareSigns')
  let content = map(signs, "v:val.line . '|' . getline(v:val.line)")

  call TempWindow('[Sign List]', content)

  set ft=qf
  nnoremap <silent> <buffer> <cr> :call <SID>JumpToSign()<cr>

  " Store filename so that plugins can use it if necessary.
  let b:filename = filename
  augroup temp_window
    autocmd! BufWinLeave <buffer>
    call GoToBufferWindowRegister(filename)
  augroup END
endfunction " }}}

" JumpToSign() eclim/autoload/eclim/display/signs.vim {{{2
function! s:JumpToSign()
  let winnr = bufwinnr(bufnr('^' . b:filename))
  if winnr != -1
    let line = substitute(getline('.'), '^\(\d\+\)|.*', '\1', '')
    exec winnr . "winc w"
    call cursor(line, 1)
  endif
endfunction " }}}

" GetExisting(...) eclim/autoload/eclim/display/signs.vim {{{2
" Gets a list of existing signs for the current buffer.
" The list consists of dictionaries with the following keys:
"   id:   The sign id.
"   line: The line number.
"   name: The sign name (erorr, warning, etc.)
"
" Optionally a sign name may be supplied to only retrieve signs of that name.
function! SignsGetExisting(...)
  let bufnr = bufnr('%')

  redir => signs
  silent exec 'sign place buffer=' . bufnr
  redir END

  let existing = []
  for sign in split(signs, '\n')
    if sign =~ 'id='
      " for multi language support, don't have have regex w/ english
      " identifiers
      let id = substitute(sign, '.\{-}=.\{-}=\(.\{-}\)\s.*', '\1', '')
      exec 'let line = ' . substitute(sign, '.\{-}=\(.\{-}\)\s.*', '\1', '')
      let name = substitute(sign, '.\{-}=.\{-}=.\{-}=\(.\{-}\)\s*$', '\1', '')
      call add(existing, {'id': id, 'line': line, 'name': name})
    endif
  endfor

  if len(a:000) > 0
    call filter(existing, "v:val['name'] == a:000[0]")
  endif

  return existing
endfunction " }}}

" HasExisting(...) eclim/autoload/eclim/display/signs.vim {{{2
" Determines if there are an existing signs.
" Optionally a sign name may be supplied to only test for signs of that name.
function! SignsHasExisting(...)
  let bufnr = bufnr('%')

  redir => results
  silent exec 'sign place buffer=' . bufnr
  redir END

  for sign in split(results, '\n')
    if sign =~ 'id='
      if len(a:000) == 0
        return 1
      endif
      let name = substitute(sign, '.\{-}=.\{-}=.\{-}=\(.\{-}\)\s*$', '\1', '')
      if name == a:000[0]
        return 1
      endif
    endif
  endfor

  return 0
endfunction " }}}

" Update() eclim/autoload/eclim/display/signs.vim {{{2
" Updates the signs for the current buffer.  This function will read both the
" location list and the quickfix list and place a sign for any entries for the
" current file.
" This function supports a severity level by examining the 'type' key of the
" dictionaries in the location or quickfix list.  It supports 'i' (info), 'w'
" (warning), and 'e' (error).
function! SignsUpdate()
  if !has('signs') || !g:EclimSignLevel
    return
  endif

  let save_lazy = &lazyredraw
  set lazyredraw

  call SignsDefine('error', '>>', g:EclimErrorHighlight)
  let placeholder = SignsSetPlaceholder()

  " remove all existing signs
  let existing = SignsGetExisting()
  for exists in existing
    if exists.name =~ '^\(error\|info\|warning\|qf_error\|qf_warning\)$'
      call SignsUnplace(exists.id)
    endif
  endfor

  let qflist = getqflist()

  if g:EclimShowQuickfixSigns
    let errors = filter(copy(qflist),
      \ 'bufnr("%") == v:val.bufnr && (v:val.type == "" || v:val.type == "e")')
    let warnings = filter(copy(qflist),
      \ 'bufnr("%") == v:val.bufnr && v:val.type == "w"')
    call map(errors, 'v:val.lnum')
    call map(warnings, 'v:val.lnum')
    call SignsDefine("qf_error", "> ", g:EclimErrorHighlight)
    call SignsDefine("qf_warning", "> ", g:EclimWarningHighlight)
    call SignsPlaceAll("qf_error", errors)
    call SignsPlaceAll("qf_warning", warnings)
  endif

  let list = filter(getloclist(0), 'bufnr("%") == v:val.bufnr')

  if g:EclimSignLevel >= 4
    let info = filter(copy(qflist) + copy(list),
      \ 'bufnr("%") == v:val.bufnr && v:val.type == "i"')
    let locinfo = filter(copy(list),
      \ 'bufnr("%") == v:val.bufnr && v:val.type == ""')
    call extend(info, locinfo)
    call map(info, 'v:val.lnum')
    call SignsDefine("info", ">>", g:EclimInfoHighlight)
    call SignsPlaceAll("info", info)
  endif

  if g:EclimSignLevel >= 3
    let warnings = filter(copy(list), 'v:val.type == "w"')
    call map(warnings, 'v:val.lnum')
    call SignsDefine("warning", ">>", g:EclimWarningHighlight)
    call SignsPlaceAll("warning", warnings)
  endif

  if g:EclimSignLevel >= 2
    let errors = filter(copy(list), 'v:val.type == "e"')
    call map(errors, 'v:val.lnum')
    call SignsPlaceAll("error", errors)
  endif

  if placeholder
    call SignsRemovePlaceholder()
  endif

  let &lazyredraw = save_lazy
endfunction " }}}

" Show(type, list) eclim/autoload/eclim/display/signs.vim {{{2
" Set the type on each entry in the specified list ('qf' or 'loc') and mark
" any matches in the current file.
function! SignsShow(type, list)
  if a:type != ''
    if a:list == 'qf'
      let list = getqflist()
    else
      let list = getloclist(0)
    endif

    let newentries = []
    for entry in list
      let newentry = {
          \ 'filename': bufname(entry.bufnr),
          \ 'lnum': entry.lnum,
          \ 'col': entry.col,
          \ 'text': entry.text,
          \ 'type': a:type
        \ }
      call add(newentries, newentry)
    endfor

    if a:list == 'qf'
      call setqflist(newentries, 'r')
    else
      call setloclist(0, newentries, 'r')
    endif
  endif

  call SignsUpdate()

  redraw!
endfunction " }}}

" SetPlaceholder([only_if_necessary]) eclim/autoload/eclim/display/signs.vim {{{2
" Set sign at line 1 to prevent sign column from collapsing, and subsiquent
" screen redraw.
function! SignsSetPlaceholder(...)
  if !has('signs') || !g:EclimSignLevel
    return
  endif

  if len(a:000) > 0 && a:000[0]
    let existing = SignsGetExisting()
    if !len(existing)
      return
    endif
  endif

  call SignsDefine('placeholder', '_ ', g:EclimInfoHighlight)
  let existing = SignsGetExisting('placeholder')
  if len(existing) == 0 && SignsHasExisting()
    call SignsPlace('placeholder', 1)
    return 1
  endif
  return
endfunction " }}}

" RemovePlaceholder() eclim/autoload/eclim/display/signs.vim {{{2
function! SignsRemovePlaceholder()
  if !has('signs') || !g:EclimSignLevel
    return
  endif

  let existing = SignsGetExisting('placeholder')
  for exists in existing
    call SignsUnplace(exists.id)
  endfor
endfunction " }}}

" define signs for manually added user marks. eclim/autoload/eclim/display/signs.vim {{{2
if has('signs')
  let s:name = 'user'
  exec "sign define " . s:name . " text=" . g:EclimUserSignText . " texthl=" . g:EclimUserSignHighlight
endif " }}}

" End Display Signs: }}}

" Python Django: {{{1

" GetProjectPath([path]) eclim/autoload/eclim/python/django/util.vim {{{2
function! DjangoGetProjectPath(...)
  let path = len(a:000) > 0 ? a:000[0] : escape(expand('%:p:h'), ' ')
  let dir = findfile("manage.py", path . ';')
  if dir != ''
    let dir = substitute(fnamemodify(dir, ':p:h'), '\', '/', 'g')
    " secondary check on the dir, if settings.py exists, then probably the
    " right dir, otherwise, search again from the parent.
    if !filereadable(dir . '/settings.py')
      return DjangoGetProjectPath(path . '/..')
    endif
  endif
  return dir
endfunction " }}}

" }}}

" Python Validate: {{{1

" Global Variables eclim/autoload/eclim/python/validate.vim {{{2
  " if the user has the pyflakes plugin from vim.org, then disable our
  " validation since the two overlap and may result in errors
  let s:pyflakes_enabled = 1
  if exists('g:pyflakes_builtins')
    let s:pyflakes_enabled = 0
  endif
  if !exists('g:EclimValidateBuffer')
    let g:EclimValidateBuffer = 1
  endif
" }}}

" Script Variables eclim/autoload/eclim/python/validate.vim {{{2
  let s:warnings = '\(' . join([
      \ 'imported but unused',
      \ 'local variable .* assigned to but never used',
    \ ], '\|') . '\)'
" }}}

" Validate(on_save) eclim/autoload/eclim/python/validate.vim {{{2
" Validates the current file.
function! Validate(on_save)
  if g:EclimValidateBuffer == 0
    return
  endif

  if WillWrittenBufferClose()
    return
  endif

  if &filetype != "python"
    return
  endif

  let results = []
  let syntax_error = ValidateSyntax()

  if syntax_error == ''
    if s:pyflakes_enabled
      if !executable('pyflakes')
        if !exists('g:eclim_python_pyflakes_warn')
          call EchoWarning("Unable to find 'pyflakes' command.")
          let g:eclim_python_pyflakes_warn = 1
        endif
      else
        let command = 'pyflakes "' . expand('%:p') . '"'
        let results = split(System(command), '\n')
        if v:shell_error > 1 " pyflakes returns 1 if there where warnings.
          call EchoError('Error running command: ' . command)
          let results = []
        endif
      endif
    endif

    " rope validation
    " currently too slow for running on every save.
    "
    " gryf: this stuff should be rewriten somehow. For now it is just to
    " complicated.
    "
    "if eclim#project#util#IsCurrentFileInProject(0) && !a:on_save
    "  let project = eclim#project#util#GetCurrentProjectRoot()
    "  let filename = eclim#project#util#GetProjectRelativeFilePath(expand('%:p'))
    "  let rope_results = eclim#python#rope#Validate(project, filename)
    "  " currently rope gets confused with iterator var on list comprehensions
    "  let rope_results = filter(rope_results, "v:val !~ '^Unresolved variable'")
    "  let results += rope_results
    "endif
  endif

  if !empty(results) || syntax_error != ''
    call filter(results, "v:val !~ 'unable to detect undefined names'")

    let errors = []
    if syntax_error != ''
      let lnum = substitute(syntax_error, '.*(line \(\d\+\))', '\1', '')
      let text = substitute(syntax_error, '\(.*\)\s\+(line .*', '\1', '')
      if lnum == syntax_error
        let lnum = 1
        let text .= ' (unknown line)'
      endif
      call add(errors, {
          \ 'filename': Simplify(expand('%')),
          \ 'lnum': lnum,
          \ 'text': text,
          \ 'type': 'e'
        \ })
    endif

    if syntax_error == ''
      for error in results
        let file = substitute(error, '\(.\{-}\):[0-9]\+:.*', '\1', '')
        let line = substitute(error, '.\{-}:\([0-9]\+\):.*', '\1', '')
        let message = substitute(error, '.\{-}:[0-9]\+:\(.*\)', '\1', '')
        let dict = {
            \ 'filename': Simplify(file),
            \ 'lnum': line,
            \ 'text': message,
            \ 'type': message =~ s:warnings ? 'w' : 'e',
          \ }

        call add(errors, dict)
      endfor
    endif

    call SetLocationList(errors)
    if g:EclimOpenQFLists
      :lopen
    endif
  else
    call ClearLocationList()
  endif
endfunction " }}}

" ValidateSyntax() eclim/autoload/eclim/python/validate.vim {{{2
function ValidateSyntax()
  let syntax_error = ''

  if has('python')

python << EOF
import re, vim
from compiler import parseFile
try:
  parseFile(vim.eval('expand("%:p")'))
except SyntaxError, se:
  vim.command("let syntax_error = \"%s\"" % re.sub(r'"', r'\"', str(se)))
except IndentationError, ie:
  vim.command("let syntax_error = \"%s (line %s)\"" % (
    re.sub(r'"', r'\"', ie.msg), ie.lineno)
  )
EOF

  endif

  return syntax_error
endfunction " }}}

" PyLint() eclim/autoload/eclim/python/validate.vim {{{2
function! PyLint()

  if &filetype != "python"
    return
  endif

  let file = expand('%:p')

  if !executable('pylint')
    call EchoError("Unable to find 'pylint' command.")
    return
  endif

  let pylint_env = ''
  if exists('g:EclimPyLintEnv')
    let pylint_env = g:EclimPyLintEnv
  else
    let paths = []

    let django_dir = DjangoGetProjectPath()
    if django_dir != ''
      call add(paths, fnamemodify(django_dir, ':h'))
      let settings = fnamemodify(django_dir, ':t')
      if has('win32') || has('win64')
        let pylint_env =
          \ 'set DJANGO_SETTINGS_MODULE='. settings . '.settings && '
      else
        let pylint_env =
          \ 'DJANGO_SETTINGS_MODULE="'. settings . '.settings" '
      endif
    endif

    if !empty(paths)
      if has('win32') || has('win64')
        let pylint_env .= 'set "PYTHONPATH=' . join(paths, ';') . '" && '
      else
        let pylint_env .= 'PYTHONPATH="$PYTHONPATH:' . join(paths, ':') . '"'
      endif
    endif
  endif

  " TODO: switch to 'parseable' output format.
  let command = pylint_env .
    \ ' pylint --reports=n --output-format=text "' . file . '"'
  if has('win32') || has('win64')
    let command = 'cmd /c "' . command . '"'
  endif

  call Echo('Running pylint (ctrl-c to cancel) ...')
  let result = System(command)
  call Echo(' ')
  if v:shell_error == 1
    call EchoError('Error running command: ' . command)
    return
  endif

  if result =~ ':'
    let errors = []
    for error in split(result, '\n')
      if error =~ '^[CWERF]\(: \)\?[0-9]'
        let line = substitute(error, '.\{-}:\s*\([0-9]\+\):.*', '\1', '')
        let message = substitute(error, '.\{-}:\s*[0-9]\+:\(.*\)', '\1', '')
        let dict = {
            \ 'filename': Simplify(file),
            \ 'lnum': line,
            \ 'text': message,
            \ 'type': error =~ '^E' ? 'e' : 'w',
          \ }

        call add(errors, dict)
      endif
    endfor
    call SetQuickfixList(errors)
    if g:EclimOpenQFLists
      :copen
    endif
  else
    call SetQuickfixList([], 'r')
  endif
endfunction " }}}

" }}}

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
  let b:eclim_temp_window = 1
  setlocal nowrap winfixheight
  setlocal noswapfile nobuflisted nonumber
  setlocal buftype=nofile bufhidden=delete
  nnoremap <buffer> <silent> ? :bd<cr>

  set modifiable noreadonly
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

" Gryf: {{{1

" GetAllBuffers {{{2
function! GetAllBuffers()
  redir => list
  silent exec 'buffers'
  redir END

  for entry in split(list, '\n')
      echo entry
  endfor
  echo expand('%:p')

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

  echo buffers
  return buffers

  "let buffers = []
  "let filelength = 0
  "for entry in split(list, '\n')
  "  let buffer = {}
  "  let buffer.status = substitute(entry, '\s*[0-9]\+\s\+\(.\{-}\)\s\+".*', '\1', '')
  "  let buffer.path = substitute(entry, '.\{-}"\(.\{-}\)".*', '\1', '')
  "  let buffer.path = fnamemodify(buffer.path, ':p')
  "  let buffer.file = fnamemodify(buffer.path, ':p:t')
  "  let buffer.dir = fnamemodify(buffer.path, ':p:h')
  "  exec 'let buffer.bufnr = ' . substitute(entry, '\s*\([0-9]\+\).*', '\1', '')
  "  exec 'let buffer.lnum = ' .
  "    \ substitute(entry, '.*"\s\+line\s\+\([0-9]\+\).*', '\1', '')
  "  call add(buffers, buffer)

  "  if len(buffer.file) > filelength
  "    let filelength = len(buffer.file)
  "  endif
  "endfor

  "if g:EclimBuffersSort != ''
  "  call sort(buffers, 'BufferCompare')
  "endif

  "let lines = []
  "for buffer in buffers
  "  call add(lines, s:BufferEntryToLine(buffer, filelength))
  "endfor

  "call TempWindow('[buffers]', lines)
  "let b:eclim_buffers = buffers

  "" syntax
  "set ft=eclim_buffers
  "hi link BufferActive Special
  "hi link BufferHidden Comment
  "syntax match BufferActive /+\?active\s\+\(\[RO\]\)\?/
  "syntax match BufferHidden /+\?hidden\s\+\(\[RO\]\)\?/

  "" mappings
  "nnoremap <silent> <buffer> <cr> :call <SID>BufferOpen(g:EclimBuffersDefaultAction)<cr>
  "nnoremap <silent> <buffer> E :call <SID>BufferOpen('edit')<cr>
  "nnoremap <silent> <buffer> S :call <SID>BufferOpen('split')<cr>
  "nnoremap <silent> <buffer> T :call <SID>BufferOpen('tablast \| tabnew')<cr>
  "nnoremap <silent> <buffer> D :call <SID>BufferDelete()<cr>

  "augroup eclim_buffers
  "  autocmd!
  "  autocmd BufAdd,BufWinEnter,BufDelete,BufWinLeave *
  "    \ call eclim#common#buffers#BuffersUpdate()
  "  autocmd BufUnload <buffer> autocmd! eclim_buffers
  "augroup END
endfunction " }}}

" ViewAllSigns(name) {{{2
" Open a window to view all placed signs with the given name in the all
" buffers.
function! SignsViewAllSigns(name)
  for buf in GetAllBuffers()
      echo buf
  endfor
  return

    if buf.file not in ('[Quickfix List]', '[Location List]')
      let filename = expand("%:p") "buf.path
      let signs = SignsGetExisting(a:name)
      call sort(signs, 's:CompareSigns')
      let content = map(signs, "v:val.line . '|' . getline(v:val.line)")

      call TempWindow('[Sign List]', content)

      set ft=qf
      nnoremap <silent> <buffer> <cr> :call <SID>JumpToSign()<cr>

      " Store filename so that plugins can use it if necessary.
      let b:filename = filename
      augroup temp_window
        autocmd! BufWinLeave <buffer>
        call GoToBufferWindowRegister(filename)
      augroup END
    endif
  endfor

  "let filename = expand('%:p')
  "let signs = SignsGetExisting(a:name)
  "call sort(signs, 's:CompareSigns')
  "let content = map(signs, "v:val.line . '|' . getline(v:val.line)")

  "call TempWindow('[Sign List]', content)

  "set ft=qf
  "nnoremap <silent> <buffer> <cr> :call <SID>JumpToSign()<cr>

  "" Store filename so that plugins can use it if necessary.
  "let b:filename = filename
  "augroup temp_window
  "  autocmd! BufWinLeave <buffer>
  "  call GoToBufferWindowRegister(filename)
  "augroup END
endfunction " }}}

" TODO: remove this
map <F4> <esc>:Signs<cr>
map <F3> <esc>:Sign<cr>

" GetAllExisting(...) {{{2
" Gets a list of existing signs for all the buffers.
" The list consists of dictionaries with the following keys:
"   buffer: Buffer number
"   id:     The sign id.
"   line:   The line number.
"   name:   The sign name (erorr, warning, etc.)
"
" Optionally a sign name may be supplied to only retrieve signs of that name.
function! SignsGetAllExisting(buffernr, mark_name)
  let bufnr = bufnr('%')

  redir => signs
  silent exec 'sign place buffer=' . a:buffernr
  redir END

  let existing = []
  for sign in split(signs, '\n')
    if sign =~ 'id='
      " for multi language support, don't have have regex w/ english
      " identifiers
      let id = substitute(sign, '.\{-}=.\{-}=\(.\{-}\)\s.*', '\1', '')
      exec 'let line = ' . substitute(sign, '.\{-}=\(.\{-}\)\s.*', '\1', '')
      let name = substitute(sign, '.\{-}=.\{-}=.\{-}=\(.\{-}\)\s*$', '\1', '')
      call add(existing, {'id': id, 'line': line, 'name': name})
    endif
  endfor

  if len(a:000) > 0
    call filter(existing, "v:val['name'] == a:mark_name")
  endif

  return existing
endfunction " }}}

" PyLintBuf() create pylint-output buffer {{{2
function! PyLintBuf()

  if &filetype != "python"
    return
  endif

  let file = expand('%:p')

  if !executable('pylint')
    call EchoError("Unable to find 'pylint' command.")
    return
  endif

  let pylint_env = ''
  if exists('g:EclimPyLintEnv')
    let pylint_env = g:EclimPyLintEnv
  else
    let paths = []

    if !empty(paths)
      if has('win32') || has('win64')
        let pylint_env .= 'set "PYTHONPATH=' . join(paths, ';') . '" && '
      else
        let pylint_env .= 'PYTHONPATH="$PYTHONPATH:' . join(paths, ':') . '"'
      endif
    endif
  endif

  " TODO: switch to 'parseable' output format.
  let command = pylint_env .
    \ ' pylint --reports=n --output-format=text "' . file . '"'
  if has('win32') || has('win64')
    let command = 'cmd /c "' . command . '"'
  endif

  call Echo('Running pylint (ctrl-c to cancel) ...')
  let result = System(command)
  call Echo(' ')
  if v:shell_error == 1
    call EchoError('Error running command: ' . command)
    return
  endif

  exec "bel silent new " . file . ".lint"

  for i in split(result, "\n")
      call append("$", i)
  endfor

  "remove first empty line
  exec "delete 1"
endfunction " }}}

" Marks() {{{2
" Like, :marks, but opens a temporary buffer.
function! Marks()
    redir => list
    silent exec 'marks'
    redir END

    let marks = []
    let filelength = 0
    for entry in split(list, '\n')
        echo entry
        let buffer = {}
        let buffer.status = substitute(entry, '\s*[0-9]\+\s\+\(.\{-}\)\s\+".*', '\1', '')
        let buffer.path = substitute(entry, '.\{-}"\(.\{-}\)".*', '\1', '')
        let buffer.path = fnamemodify(buffer.path, ':p')
        let buffer.file = fnamemodify(buffer.path, ':p:t')
        let buffer.dir = fnamemodify(buffer.path, ':p:h')
        exec 'let buffer.bufnr = ' . substitute(entry, '\s*\([0-9]\+\).*', '\1', '')
        exec 'let buffer.lnum = ' .
                    \ substitute(entry, '.*"\s\+line\s\+\([0-9]\+\).*', '\1', '')
        call add(marks, buffer)

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

    call TempWindow('[marks]', lines)
    let b:eclim_buffers = buffers

    " syntax
    set ft=eclim_buffers
    hi link BufferActive Special
    hi link BufferHidden Comment
    syntax match BufferActive /+\?active\s\+\(\[RO\]\)\?/
    syntax match BufferHidden /+\?hidden\s\+\(\[RO\]\)\?/

    " mappings
    nnoremap <silent> <buffer> <cr> :call <SID>BufferOpen(g:EclimBuffersDefaultAction)<cr>
    nnoremap <silent> <buffer> E :call <SID>BufferOpen('edit')<cr>
    nnoremap <silent> <buffer> S :call <SID>BufferOpen('split')<cr>
    nnoremap <silent> <buffer> T :call <SID>BufferOpen('tablast \| tabnew')<cr>
    nnoremap <silent> <buffer> D :call <SID>BufferDelete()<cr>

    "augroup eclim_buffers
    "  autocmd!
    "  autocmd BufAdd,BufWinEnter,BufDelete,BufWinLeave *
    "    \ call eclim#common#buffers#BuffersUpdate()
    "  autocmd BufUnload <buffer> autocmd! eclim_buffers
    "augroup END
endfunction " }}}
command Marks :call Marks()

" s:BufferOpen2(cmd) {{{2
function! s:BufferOpen2(cmd)
  let line = line('.')
  if line > len(b:eclim_buffers)
    return
  endif

  let bufnr = b:eclim_buffers[line - 1].bufnr
  let winnr = b:winnr
  close
  exec winnr . 'winc w'
  call GoToBufferWindowOrOpen2(bufnr, a:cmd)
endfunction " }}}

" GoToBufferWindowOrOpen2(nr, cmd) {{{2
" modified function GoToBufferWindowOrOpen. instead of buffer name it accepts
" buffer number.
function! GoToBufferWindowOrOpen2(nr, cmd)
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

" ToggleQFonValidate() {{{2
" Nice on/off feature for open/not open qf window after save validation. To be
" mapped on convinent shortcut or called in command line.
function! ToggleQFonValidate()
    if g:EclimOpenQFLists
        let g:EclimOpenQFLists = 0
        call Echo('QF on validate off')
    else
        let g:EclimOpenQFLists = 1
        call Echo('QF on validate on')
    endif
endfun " }}}

" }}}

" vim:ft=vim:fdm=marker

