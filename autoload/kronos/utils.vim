" ------------------------------------------------------------------ # Compose #

function kronos#utils#compose(...)
  let funcs = map(reverse(copy(a:000)), 'function(v:val)')
  return function('s:compose', [funcs])
endfunction

function s:compose(funcs, arg)
  let data = a:arg

  for Func in a:funcs
    let data = Func(data)
  endfor

  return data
endfunction

" --------------------------------------------------------------------- # Trim #

function kronos#utils#trim(str)
  return kronos#utils#compose('s:trim_left', 's:trim_right')(a:str)
endfunction

function s:trim_left(str)
  return substitute(a:str, '^\s*', '', 'g')
endfunction

function s:trim_right(str)
  return substitute(a:str, '\s*$', '', 'g')
endfunction
