if exists("b:current_syntax")
  finish
endif

syntax keyword KronosInfoKey ID DESC TAGS ACTIVE DUE WORKTIME contained

syntax region KronosInfoId        start='^\s*ID\s'hs=e+1        end='$' contains=KronosInfoKey
syntax region KronosInfoDesc      start='^\s*DESC\s'hs=e+1      end='$' contains=KronosInfoKey
syntax region KronosInfoTags      start='^\s*TAGS\s'hs=e+1      end='$' contains=KronosInfoKey
syntax region KronosInfoActive    start='^\s*ACTIVE\s'hs=e+1    end='$' contains=KronosInfoKey
syntax region KronosInfoDue       start='^\s*DUE\s'hs=e+1       end='$' contains=KronosInfoKey
syntax region KronosInfoWorktime  start='^\s*WORKTIME\s'hs=e+1  end='$' contains=KronosInfoKey

highlight default link KronosInfoKey          TabLine
highlight default link KronosInfoId           Identifier
highlight default link KronosInfoDesc         Comment
highlight default link KronosInfoTags         Tag
highlight default link KronosInfoActive       String
highlight default link KronosInfoDue          String
highlight default link KronosInfoKeyWorktime  String

let b:current_syntax = "kronosinfo"

