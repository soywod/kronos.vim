function! kronos#tool#logging#Error(msg)
  redraw
  echohl ErrorMsg
  echo a:msg
  echohl None
endfunction

function! kronos#tool#logging#Info(format, id)
  let l:id = '[' . a:id . ']'
  let [l:leftstr, l:rightstr] = split(a:format, '%')

  redraw
  echon l:leftstr
  echohl Identifier
  echon l:id
  echohl None
  echon l:rightstr
endfunction

