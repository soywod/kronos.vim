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

  silent! bdelete Kronos
  silent! new Kronos

  call append(0, l:header + l:tasks)
  normal! dd2G

  setlocal filetype=kronos
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
  let l:config = kronos#GetConfig().gui

  return join(map(
    \ l:config.order,
    \ 's:FormatTaskProp(a:task[v:val], l:config.width[v:val])',
  \), '')
endfunction

