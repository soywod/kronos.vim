if exists('b:current_syntax')
  finish
endif

syntax match kronos_wtime_separator   /[|-]/
syntax match kronos_wtime_worktime    /\(|.*|\)\@<=.*|/ contains=kronos_wtime_separator
syntax match kronos_wtime_date        /|.\{-}|/         contains=kronos_wtime_separator
syntax match kronos_wtime_total       /|.\{-}|\%$/      contains=kronos_wtime_separator,kronos_wtime_worktime
syntax match kronos_wtime_head        /.*\%1l/          contains=kronos_wtime_separator

highlight default link kronos_wtime_separator   VertSplit
highlight default link kronos_wtime_date        Comment
highlight default link kronos_wtime_worktime    String
highlight default link kronos_wtime_total       Tag

highlight kronos_wtime_head term=bold,underline cterm=bold,underline gui=bold,underline

let b:current_syntax = 'kwtime'
