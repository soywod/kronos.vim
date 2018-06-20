function! kronos#EntryPoint(args)
  if a:args =~? '^ *$' | return kronos#ui#gui#ShowList() | endif

  let farg = split(a:args, ' ')[0]
  let args = a:args[len(farg) + 1:]

  if farg =~? '^ad\?d\?$'
    return kronos#ui#cli#Add(g:kronos_database, localtime(), args)
  elseif farg =~? '^in\?f\?o\?$'
    return kronos#ui#cli#Info(g:kronos_database, args)
  elseif farg =~? '^li\?s\?t\?$'
    return kronos#ui#cli#List(g:kronos_database)
  elseif farg =~? '^up\?d\?a\?t\?e\?$'
    return kronos#ui#cli#Update(g:kronos_database, localtime(), args)
  elseif farg =~? '^de\?l\?e\?t\?e\?$'
    return kronos#ui#cli#Delete(g:kronos_database, args)
  elseif farg =~? '^st\?$'
    return kronos#ui#cli#Toggle(g:kronos_database, localtime(), args)
  elseif farg =~? '^sta\?r\?t\?$'
    return kronos#ui#cli#Start(g:kronos_database, localtime(), args)
  elseif farg =~? '^sto\?p\?$'
    return kronos#ui#cli#Stop(g:kronos_database, localtime(), args)
  elseif farg =~? '^do\?n\?e\?$'
    return kronos#ui#cli#Done(g:kronos_database, localtime(), args)
  endif
endfunction

