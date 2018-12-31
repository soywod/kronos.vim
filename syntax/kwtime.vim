if exists('b:current_syntax')
  finish
endif

syntax match kronos_wtime_separator /:/
syntax match kronos_wtime_date      /\d\{2}\/\d\{2}\/\d\{2}:/ contains=kronos_wtime_separator
syntax match kronos_wtime_interval  /.*/                    contains=kronos_wtime_date

highlight default link kronos_wtime_date      Identifier
highlight default link kronos_wtime_interval  String

let b:current_syntax = 'kwtime'
