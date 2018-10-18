if exists('b:current_syntax')
  finish
endif

function! s:set_syntax()
  let keys   = kronos#interface#gui#config().info.key
  let labels = kronos#interface#gui#config().label

  for key in keys
    let label    = labels[key]
    let end      = 'end=/$/'
    let start    = 'start=/^' . label . '\s*[^\s]/hs=e+1'
    let contains = 'contains=kronos_info_separator,kronos_info_key'
    let region   = 'region kronos_info_' . key

    execute join(['syntax', region, start, end, contains], ' ')
  endfor

  syntax match kronos_info_separator /|/
  syntax match kronos_info_head      /.*\%1l/ contains=kronos_info_separator

  execute 'syntax keyword kronos_info_key contained ' . join(values(labels), ' ')
endfunction

call s:set_syntax()

highlight default link kronos_info_active     String
highlight default link kronos_info_desc       Comment
highlight default link kronos_info_done       Structure
highlight default link kronos_info_due        String
highlight default link kronos_info_id         Identifier
highlight default link kronos_info_key        Comment
highlight default link kronos_info_lastactive String
highlight default link kronos_info_separator  VertSplit
highlight default link kronos_info_tags       Tag
highlight default link kronos_info_worktime   String

highlight kronos_info_head term=bold,underline cterm=bold,underline gui=bold,underline

let b:current_syntax = 'kinfo'
