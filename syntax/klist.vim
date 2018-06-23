if exists('b:current_syntax')
  finish
endif

function! s:SetSyntax()
  let columns = kronos#gui#Const().LIST.COLUMN
  let widths  = kronos#gui#Const().LIST.WIDTH

  let end   = 0
  let start = 1
  let due   = 79 - widths['due']

  for column in columns
    let end    = start + widths[column] - 1
    let region = 'region Kronos' . toupper(column[0]) . column[1:]

    execute 'syntax '.region.' start=/\%'.start.'c/ end=/\%'.end.'c/'
    let start = end + 1
  endfor

  syntax match KronosSeparator /|/
  syntax match KronosDone      /^-.*$/     contains=KronosSeparator
  syntax match KronosHead      /.*\%1l/    contains=KronosSeparator
  syntax match KronosDueAlert  /.*ago\s*$/ contains=KronosSeparator
endfunction

call s:SetSyntax()

highlight default link KronosActive     String
highlight default link KronosDesc       Comment
highlight default link KronosDone       VertSplit
highlight default link KronosDue        Structure
highlight default link KronosDueAlert   Error
highlight default link KronosId         Identifier
highlight default link KronosSeparator  VertSplit
highlight default link KronosTags       Tag

highlight KronosHead term=bold,underline cterm=bold,underline

let b:current_syntax = 'klist'

