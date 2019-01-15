" ---------------------------------------------------------------- # Localtime #

function! kronos#utils#date#localtime()
  return localtime() * 1000
endfunction

" ----------------------------------------------------------------- # Strftime #

function! kronos#utils#date#strftime(format, time)
  return strftime(a:format, a:time[:9])
endfunction
