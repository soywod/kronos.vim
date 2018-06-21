function! kronos#tool#logging#Error(msg)
  redraw
  echohl ErrorMsg
  echon a:msg
  echohl None
endfunction

function! kronos#tool#logging#Info(format, id)
  try
    let [leftstr, rightstr] = split(a:format, '%')
  catch
    let leftstr  = ''
    let rightstr = a:format =~? '^%' ? a:format[1:] : a:format
  endtry

  echohl None
  echon leftstr

  if (a:id + 1)
    echohl Comment
    echon '['
    echohl Identifier
    echon a:id + 1 ? a:id : ''
    echohl Comment
    echon ']'
  endif

  echohl None
  echon rightstr
endfunction

