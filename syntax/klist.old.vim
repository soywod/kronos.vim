if exists('b:current_syntax')
  finish
endif

function! s:set_syntax()
  let columns = kronos#interface#gui#config().list.column
  let widths  = kronos#interface#gui#config().list.width

  let end   = 0
  let start = 1
  let due   = 79 - widths['due']

  for column in columns
    let end    = start + widths[column] - 1
    let region = 'region kronos_' . column[0] . column[1:]

    execute 'syntax '.region.' start=/\%'.start.'c/ end=/\%'.end.'c/'
    let start = end + 1
  endfor

  syntax match kronos_separator /|/
  syntax match kronos_done      /^-.*$/     contains=kronos_separator
  syntax match kronos_head      /.*\%1l/    contains=kronos_separator
  syntax match kronos_due_alert /.*ago\s*$/ contains=kronos_separator
endfunction

call s:set_syntax()

highlight default link kronos_active    String
highlight default link kronos_desc      Comment
highlight default link kronos_done      VertSplit
highlight default link kronos_due       Structure
highlight default link kronos_due_alert Error
highlight default link kronos_id        Identifier
highlight default link kronos_separator VertSplit
highlight default link kronos_tags      Tag

highlight kronos_head term=bold,underline cterm=bold,underline gui=bold,underline

let b:current_syntax = 'klist.old'
