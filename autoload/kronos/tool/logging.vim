function! kronos#tool#logging#Error(msg)
  echohl ErrorMsg
  echo a:msg
  echohl None
endfunction

