function! WordFrequency() range
  let all = split(join(getline(a:firstline, a:lastline)), '\k\+')
  let frequencies = {}
  for word in all
    let frequencies[word] = get(frequencies, word, 0) + 1
  endfor
  new
  setlocal buftype=nofile bufhidden=hide noswapfile tabstop=4
  for [key,value] in items(frequencies)
    call append('$', value."\t".key)
  endfor
  sort i
endfunction
command! -range=% WordFrequency <line1>,<line2>call WordFrequency()

function! CreateDict() range
  let all = split(join(getline(a:firstline, a:lastline)), '[^A-Za-zęóąśłżźćńĘÓĄŚŁŻŹĆŃ]\+')
  let frequencies = {}
  for word in all
    let frequencies[word] = get(frequencies, word, 0) + 1
  endfor
  new
  setlocal buftype=nofile bufhidden=hide noswapfile
  for [key,value] in items(frequencies)
    call append('$', key)
  endfor
  sort i
endfunction
command! -range=% CreateDict <line1>,<line2>call CreateDict()
