if exists("b:current_syntax")
  finish
endif

function! s:SetSyntax()
  let l:config = kronos#GetConfig().gui
  let l:start = 1
  let l:end = 0

  for l:colname in l:config.order
    let l:end = l:start + l:config.width[l:colname] - 1
    let l:region = 'region Kronos' . toupper(l:colname[0]) . l:colname[1:]

    execute 'syntax '.l:region.' start=/\%'.l:start.'c/ end=/\%'.l:end.'c/'
    let l:start = l:end + 1
  endfor

  syntax match KronosHead /.*\%1l/
endfunction

call s:SetSyntax()

highlight default link KronosHead   TabLine
highlight default link KronosId     Identifier
highlight default link KronosDesc   Comment
highlight default link KronosTags   Tag
highlight default link KronosActive String
highlight default link KronosDue    String

let b:current_syntax = "kronos"

