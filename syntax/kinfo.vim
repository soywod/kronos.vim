if exists('b:current_syntax')
  finish
endif

function! s:SetSyntax()
  let keys   = kronos#gui#Const().INFO.KEY
  let labels = kronos#gui#Const().LABEL

  for key in keys
    let label    = labels[key]
    let end      = 'end=/$/'
    let start    = 'start=/^' . label . '\s*[^\s]/hs=e+1'
    let contains = 'contains=KronosInfoSeparator,KronosInfoKey'
    let region   = 'region KronosInfo' . toupper(key[0]) . key[1:]

    execute join(['syntax', region, start, end, contains], ' ')
  endfor

  syntax match KronosInfoSeparator /|/
  syntax match KronosInfoHead      /.*\%1l/ contains=KronosInfoSeparator

  execute 'syntax keyword KronosInfoKey contained ' . join(values(labels), ' ')
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

let b:current_syntax = 'kinfo'

