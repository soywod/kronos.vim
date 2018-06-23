function! kronos#tool#log#Error(msg)
  redraw
  echohl ErrorMsg
  echo a:msg
  echohl None
endfunction

function! kronos#tool#log#Info(msg)
  echo a:msg
endfunction

