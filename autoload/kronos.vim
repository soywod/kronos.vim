"---------------------------------------------------------------------# Action #

function! s:Actions(dateref, args)
  return [
    \['^li\?s\?t\?$'            , 'List'    , []],
    \['^in\?f\?o\?$'            , 'Info'    , [a:args]],
    \['^dele\?t\?e\?$'          , 'Delete'  , [a:args]],
    \['^ad\?d\?$'               , 'Add'     , [a:dateref, a:args]],
    \['^up\?d\?a\?t\?e\?$'      , 'Update'  , [a:dateref, a:args]],
    \['^sta\?r\?t\?$'           , 'Start'   , [a:dateref, a:args]],
    \['^sto\?p\?$'              , 'Stop'    , [a:dateref, a:args]],
    \['^[st]$'                  , 'Toggle'  , [a:dateref, a:args]],
    \['^do\?n\?e\?$'            , 'Done'    , [a:dateref, a:args]],
    \['^wo\?r\?k\?t\?i\?m\?e\?$', 'Worktime', [a:dateref, a:args]],
  \]
endfunction

"----------------------------------------------------------------# Entry point #

function! kronos#EntryPoint(args)
  if a:args =~? '^ *$' | return kronos#ui#gui#ShowList() | endif

  let farg = split(a:args, ' ')[0]
  let args = a:args[len(farg) + 1:]

  for [regex, action, params] in s:Actions(localtime(), args)
    if farg =~? regex | return s:Trigger(action, params) | endif
  endfor

  return kronos#tool#logging#Error('Command not found.')
endfunction

"---------------------------------------------------------------------# Helper #

function! s:Trigger(action, params)
  let params = empty(a:params) ? '' : ', ' . join(a:params, ', ')
  execute 'call kronos#ui#cli#' . a:action . '(g:kronos_database' . params . ')'
endfunction

