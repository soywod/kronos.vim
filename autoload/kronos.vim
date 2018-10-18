let s:actions = [
  \['^li\?s\?t\?$'            , 'list'    ],
  \['^in\?f\?o\?$'            , 'info'    ],
  \['^dele\?t\?e\?$'          , 'delete'  ],
  \['^ad\?d\?$'               , 'add'     ],
  \['^up\?d\?a\?t\?e\?$'      , 'update'  ],
  \['^star\?t\?$'             , 'start'   ],
  \['^stop\?$'                , 'stop'    ],
  \['^to\?g\?g\?l\?e\?$'      , 'toggle'  ],
  \['^do\?n\?e\?$'            , 'done'    ],
  \['^und\?o\?n\?e\?$'        , 'undone'  ],
  \['^wo\?r\?k\?t\?i\?m\?e\?$', 'worktime'],
  \['^co\?n\?t\?e\?x\?t\?$'   , 'context' ],
\]

" -------------------------------------------------------------- # Entry point #

function! kronos#entry_point(args)
  if a:args =~? '^ *$'
    return kronos#interface#gui#list()
  endif

  let first_arg = split(a:args, ' ')[0]
  let args = a:args[len(first_arg) + 1:]

  for [regex, action] in s:actions
    if first_arg =~? regex
      return s:trigger(action, args)
    endif
  endfor

  call kronos#utils#log#error('Command not found.')
endfunction

" -------------------------------------------------------------------- # Utils #

function! s:trigger(action, args)
  execute 'call kronos#interface#cli#' . a:action . '("' . a:args . '")'
endfunction
