function! kronos#EntryPoint(args)
  if a:args =~? '^ *$' | return kronos#ui#gui#ShowList() | endif

  let farg = split(a:args, ' ')[0]
  let args = a:args[len(farg) + 1:]

  let database = g:kronos_database
  let now      = localtime()

  if farg =~? '^ad\?d\?$'
    return kronos#ui#cli#Add(database, now, args)
  elseif farg =~? '^in\?f\?o\?$'
    return kronos#ui#cli#Info(database, args)
  elseif farg =~? '^li\?s\?t\?$'
    return kronos#ui#cli#List(database)
  elseif farg =~? '^up\?d\?a\?t\?e\?$'
    return kronos#ui#cli#Update(database, now, args)
  elseif farg =~? '^dele\?t\?e\?$'
    return kronos#ui#cli#Delete(database, args)
  elseif farg =~? '^sta\?r\?t\?$'
    return kronos#ui#cli#Start(database, now, args)
  elseif farg =~? '^sto\?p\?$'
    return kronos#ui#cli#Stop(database, now, args)
  elseif farg =~? '^[st]$'
    return kronos#ui#cli#Toggle(database, now, args)
  elseif farg =~? '^do\?n\?e\?$'
    return kronos#ui#cli#Done(database, now, args)
  elseif farg =~? '^wo\?r\?k\?t\?i\?m\?e\?$'
    return kronos#ui#cli#Worktime(database, now, args)
  endif
endfunction

