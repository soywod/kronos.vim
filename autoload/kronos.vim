function! kronos#EntryPoint(args)
  if empty(a:args) | return kronos#ui#gui#ShowList() | endif

  let farg = split(a:args, ' ')[0]
  let args = a:args[len(farg)+1:]

  if farg =~? '^\(a\|add\)'
    echo 'add'
    return kronos#ui#cli#Add(g:kronos_database, localtime(), args)
  elseif farg =~? '^\(i\|info\)'
    return kronos#ui#cli#Info(g:kronos_database, args)
  endif
endfunction

