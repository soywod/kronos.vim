function! kronos#utils#log#error(msg)
  redraw
  echohl ErrorMsg
  echo 'Kronos: ' . a:msg . '.'
  echohl None
endfunction

function! kronos#utils#log#info(msg)
  echo a:msg
endfunction
