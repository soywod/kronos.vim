if exists("b:current_syntax")
  finish
endif

function! s:SetSyntax()
  let l:keys = kronos#ui#gui#Const().INFO.KEY
  let l:labels = kronos#ui#gui#Const().LABEL

  for l:key in l:keys
    let l:contains = 'contains=KronosInfoSeparator,KronosInfoKey'
    let l:end = 'end=/$/'
    let l:label = l:labels[l:key]
    let l:region = 'region KronosInfo' . toupper(l:key[0]) . l:key[1:]
    let l:start = 'start=/^' . l:label . '\s*[^\s]/hs=e+1'

    execute join(['syntax', l:region, l:start, l:end, l:contains], ' ')
  endfor

  syntax match KronosInfoSeparator /|/
  syntax match KronosInfoHead /.*\%1l/ contains=KronosInfoSeparator
  execute 'syntax keyword KronosInfoKey contained ' . join(values(l:labels), ' ')
endfunction

call s:SetSyntax()

highlight default link KronosInfoActive       String
highlight default link KronosInfoDesc         Comment
highlight default link KronosInfoDone         Structure
highlight default link KronosInfoDue          String
highlight default link KronosInfoId           Identifier
highlight default link KronosInfoKey          Comment
highlight default link KronosInfoLastactive   String
highlight default link KronosInfoSeparator    VertSplit
highlight default link KronosInfoTags         Tag
highlight default link KronosInfoWorktime     String

highlight KronosInfoHead term=bold,underline cterm=bold,underline

let b:current_syntax = "kinfo"

