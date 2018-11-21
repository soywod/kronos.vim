function! kronos#utils#log#error(msg)
  redraw
  echohl ErrorMsg
  echom 'Kronos: ' . a:msg . '.'
  echohl None
endfunction

function! kronos#utils#log#info(msg)
  echom a:msg
endfunction
