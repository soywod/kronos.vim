if exists('b:current_syntax')
  finish
endif

syntax match kronos_info_separator  /|/
syntax match kronos_info_head       /.*\%1l/              contains=kronos_info_separator
syntax match kronos_info_id         /\(|.*\)\@<=|.*|\%2l/ contains=kronos_info_separator
syntax match kronos_info_desc       /\(|.*\)\@<=|.*|\%3l/ contains=kronos_info_separator
syntax match kronos_info_tags       /\(|.*\)\@<=|.*|\%4l/ contains=kronos_info_separator
syntax match kronos_info_active     /\(|.*\)\@<=|.*|\%5l/ contains=kronos_info_separator
syntax match kronos_info_due        /\(|.*\)\@<=|.*|\%6l/ contains=kronos_info_separator
syntax match kronos_info_done       /\(|.*\)\@<=|.*|\%7l/ contains=kronos_info_separator
syntax match kronos_info_worktime   /\(|.*\)\@<=|.*|\%8l/ contains=kronos_info_separator

highlight default link kronos_info_active     Structure
highlight default link kronos_info_desc       Comment
highlight default link kronos_info_done       Structure
highlight default link kronos_info_due        String
highlight default link kronos_info_id         Identifier
highlight default link kronos_info_key        Comment
highlight default link kronos_info_separator  VertSplit
highlight default link kronos_info_tags       Tag
highlight default link kronos_info_worktime   String

highlight kronos_info_head term=bold,underline cterm=bold,underline gui=bold,underline

let b:current_syntax = 'kinfo'
