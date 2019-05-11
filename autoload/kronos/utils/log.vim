" --------------------------------------------------------------------- # Info #

function! kronos#utils#log#info(msg)
  echohl None
  echom a:msg
endfunction

" -------------------------------------------------------------------- # Error #

function! kronos#utils#log#error(msg)
  redraw
  echohl ErrorMsg
  echom 'Kronos: ' . a:msg . '.'
  echohl None
endfunction
