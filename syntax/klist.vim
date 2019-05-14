if exists('b:current_syntax')
  finish
endif

syntax match kronos_separator /|/

syntax match kronos_due /:\%(\%(\d\+\%(y\|mo\|w\|d\|h\|m\)\)\+\|\d\{1,6}\%(:\d\{1,4}\)\=\|\d\{,6}:\d\{1,4}\)/
syntax match kronos_tag /+[a-zA-Z0-9\-_]\+/

syntax match kronos_table_id     /^|.\{-}|/                              contains=kronos_separator
syntax match kronos_table_desc   /^|.\{-}|.\{-}|/                        contains=kronos_table_id,kronos_separator
syntax match kronos_table_tags   /^|.\{-}|.\{-}|.\{-}|/                  contains=kronos_table_id,kronos_table_desc,kronos_separator
syntax match kronos_table_active /^|.\{-}|.\{-}|.\{-}|.\{-}|/            contains=kronos_table_id,kronos_table_desc,kronos_table_tags,kronos_separator
syntax match kronos_table_due    /^|.\{-}|.\{-}|.\{-}|.\{-}|.\{-}|/      contains=kronos_table_id,kronos_table_desc,kronos_table_tags,kronos_table_active,kronos_separator
syntax match kronos_table_due_alert /^|.\{-}|.\{-}|.\{-}|.\{-}|.*ago.*|/ contains=kronos_table_id,kronos_table_desc,kronos_table_tags,kronos_table_active,kronos_separator

syntax match kronos_table_done      /^|-.*/  contains=kronos_separator
syntax match kronos_table_head      /.*\%1l/ contains=kronos_separator

highlight default link kronos_separator       VertSplit
highlight default link kronos_table_active    String
highlight default link kronos_table_desc      Comment
highlight default link kronos_table_done      VertSplit
highlight default link kronos_table_due       Structure
highlight default link kronos_table_due_alert Error
highlight default link kronos_table_id        Identifier
highlight default link kronos_table_tags      Tag

highlight default link kronos_due kronos_table_due
highlight default link kronos_tag kronos_table_tags

highlight kronos_table_head term=bold,underline cterm=bold,underline gui=bold,underline

let b:current_syntax = 'klist'
