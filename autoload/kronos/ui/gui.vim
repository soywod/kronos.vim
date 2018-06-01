let s:ID_LEN = 5
let s:DESC_LEN = 30
let s:TAGS_LEN = 19
let s:ACTIVE_LEN = 13
let s:DUE_LEN = 13

function! kronos#ui#gui#Start(database)
  let l:tasks = kronos#api#task#ReadAll(a:database)
  let l:header = [{
    \ 'id': 'ID',
    \ 'desc': 'DESC',
    \ 'tags': 'TAGS',
    \ 'due': 'DUE',
    \ 'active': 'ACTIVE',
  \}]

  call map(l:header, function('kronos#ui#gui#FormatHeaderLine'))
  call map(l:tasks, function('kronos#ui#gui#FormatTaskLine'))

  silent! new Kronos
  let s:buffer = bufnr('%')

  call append(0, l:header + l:tasks)
  normal! ddggj

  setlocal buftype=nofile
  setlocal cursorline
  setlocal nomodifiable
  setlocal nowrap
  setlocal startofline
endfunction

function! kronos#ui#gui#FormatHeaderLine(_, task)
  return s:FormatTaskLine(a:task)
endfunction

function! kronos#ui#gui#FormatTaskLine(_, task)
  let l:task = copy(a:task)
  let l:task.id = string(l:task.id)
  let l:task.desc = l:task.desc
  let l:task.tags = join(l:task.tags, ' ')
  let l:task.due = l:task.due
  let l:task.active = l:task.active

  return s:FormatTaskLine(l:task)
endfunction

function! s:FormatTaskProp(prop, maxlen)
  let l:maxlen = a:maxlen - 2
  let l:proplen = strdisplaywidth(a:prop[:l:maxlen])

  return a:prop[:l:maxlen] . repeat(' ', a:maxlen - l:proplen)
endfunction

function! s:FormatTaskLine(task)
  let l:idstr = s:FormatTaskProp(a:task.id, s:ID_LEN)
  let l:descstr = s:FormatTaskProp(a:task.desc, s:DESC_LEN)
  let l:tagsstr = s:FormatTaskProp(a:task.tags, s:TAGS_LEN)
  let l:duestr = s:FormatTaskProp(a:task.due, s:DUE_LEN)
  let l:activestr = s:FormatTaskProp(a:task.active, s:ACTIVE_LEN)

  return l:idstr . l:descstr . l:tagsstr . l:duestr . l:activestr
endfunction

