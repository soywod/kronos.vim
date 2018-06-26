" ------------------------------------------------------------------- # Action #

function! s:Actions(dateref, args)
  return [
    \['^li\?s\?t\?$'            , 'List'    ],
    \['^in\?f\?o\?$'            , 'Info'    ],
    \['^dele\?t\?e\?$'          , 'Delete'  ],
    \['^ad\?d\?$'               , 'Add'     ],
    \['^up\?d\?a\?t\?e\?$'      , 'Update'  ],
    \['^star\?t\?$'             , 'Start'   ],
    \['^stop\?$'                , 'Stop'    ],
    \['^to\?g\?g\?l\?e\?$'      , 'Toggle'  ],
    \['^do\?n\?e\?$'            , 'Done'    ],
    \['^und\?o\?n\?e\?$'        , 'Undone'  ],
    \['^wo\?r\?k\?t\?i\?m\?e\?$', 'Worktime'],
  \]
endfunction

" -------------------------------------------------------------- # Entry point #

function! kronos#EntryPoint(args)
  if a:args =~? '^ *$'
    return kronos#gui#List()
  endif

  let farg = split(a:args, ' ')[0]
  let args = a:args[len(farg) + 1:]

  for [regex, action] in s:Actions(localtime(), args)
    if farg =~? regex
      return s:Trigger(action, args)
    endif
  endfor

  return kronos#tool#log#Error('Command not found.')
endfunction

" ------------------------------------------------------------------- # Helper #

function! s:Trigger(action, args)
  execute 'call kronos#cli#' . a:action . '("' . a:args . '")'
endfunction

