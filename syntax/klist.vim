if exists("b:current_syntax")
  finish
endif

function! s:SetSyntax()
  let l:columns = kronos#ui#gui#Const().LIST.COLUMN
  let l:widths = kronos#ui#gui#Const().LIST.WIDTH

  let l:end = 0
  let l:start = 1

  for l:column in l:columns
    let l:end = l:start + l:widths[l:column] - 1
    let l:region = 'region Kronos' . toupper(l:column[0]) . l:column[1:]

    execute 'syntax '.l:region.' start=/\%'.l:start.'c/ end=/\%'.l:end.'c/'
    let l:start = l:end + 1
  endfor

  syntax match KronosSeparator /|/
  syntax match KronosHead /.*\%1l/ contains=KronosSeparator
endfunction

call s:SetSyntax()

highlight default link KronosActive     String
highlight default link KronosDesc       Comment
highlight default link KronosDue        String
highlight default link KronosId         Identifier
highlight default link KronosSeparator  VertSplit
highlight default link KronosTags       Tag

highlight KronosHead term=bold,underline cterm=bold,underline

let b:current_syntax = "klist"

