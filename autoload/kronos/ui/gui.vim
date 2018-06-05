let s:CONST = {
  \'INFO': {
    \'COLUMN': ['key', 'value'],
    \'KEY': ['id', 'desc', 'tags', 'active', 'lastactive', 'due', 'worktime'],
    \'WIDTH': {
      \'key'  : 15,
      \'value': 65,
    \},
  \},
  \'LABEL': {
    \'active'    : 'ACTIVE',
    \'desc'      : 'DESC',
    \'due'       : 'DUE',
    \'id'        : 'ID',
    \'key'       : 'KEY',
    \'lastactive': 'LAST ACTIVE',
    \'tags'      : 'TAGS',
    \'value'     : 'VALUE',
    \'worktime'  : 'WORKTIME',
  \},
  \'LIST': {
    \'COLUMN': ['id', 'desc', 'tags', 'active', 'due'],
    \'WIDTH': {
      \'active': 13,
      \'desc'  : 29,
      \'due'   : 13,
      \'id'    : 5,
      \'tags'  : 20,
    \},
  \},
\}

function! kronos#ui#gui#Const()
  return s:CONST
endfunction

"------------------------------------------------------------------------# Add #

function! kronos#ui#gui#Add(database, dateref)
  try
    let l:args = input('New task string: ')
    let l:id = kronos#ui#common#Add(a:database, a:dateref, l:args)
  catch
    return kronos#tool#logging#Error('Impossible to add task.')
  endtry

  call kronos#tool#logging#Info('Task % added.', l:id)
  call kronos#ui#gui#ShowList(a:database)
endfunction

"-----------------------------------------------------------------------# Info #

function! kronos#ui#gui#Info(database, id)
  try
    call kronos#ui#gui#ShowInfo(a:database, a:id)
  catch 'task-not-found'
    return kronos#tool#logging#Error('Task [' . a:id . '] not found.')
  catch
    return kronos#tool#logging#Error('Impossible to show task info.')
  endtry
endfunction

"---------------------------------------------------------------------# Delete #

function! kronos#ui#gui#Delete(database, id)
  try
    call kronos#ui#common#Delete(a:database, a:id)
  catch 'task-not-found'
    return kronos#tool#logging#Error('Task [' . a:id . '] not found.')
  catch 'operation-canceled'
    return kronos#tool#logging#Error('Operation canceled.')
  catch
    return kronos#tool#logging#Error('Impossible to delete task [' . a:id . '].')
  endtry

  call kronos#tool#logging#Info('Task % deleted.', a:id)
  call kronos#ui#gui#ShowList(a:database)
endfunction

"-----------------------------------------------------------------------# Open #

function! kronos#ui#gui#ShowList(database)
  let l:columns = s:CONST.LIST.COLUMN
  let l:headers = [filter(copy(s:CONST.LABEL), 'index(l:columns, v:key) + 1')]
  let l:prevpos = getpos('.')
  let l:tasks   = kronos#api#task#ReadAll(a:database)

  let l:headers = map(copy(l:headers), function('s:PrintListHeader'))
  let l:tasks   = map(copy(l:tasks), function('s:PrintListTask'))

  redir => l:buflist | silent! ls | redir END
  silent! edit Kronos

  if match(l:buflist, '"Kronos"') + 1
    setlocal modifiable
    execute '0,$d'
  endif

  call append(0, l:headers + l:tasks)
  execute '$d'
  call setpos('.', l:prevpos)
  setlocal filetype=klist
endfunction

"------------------------------------------------------------------# Open Info #

function! kronos#ui#gui#ShowInfo(database, id)
  let l:columns = s:CONST.INFO.COLUMN
  let l:keys    = s:CONST.INFO.KEY
  let l:labels  = s:CONST.LABEL

  let l:headers = [filter(copy(s:CONST.LABEL), 'index(l:columns, v:key) + 1')]
  let l:headers = map(copy(l:headers), function('s:PrintInfoHeader'))

  let l:task = kronos#api#task#Read(a:database, a:id)
  let l:task = kronos#ui#gui#PreparePrintTask(l:task)

  let l:keys = map(
    \copy(l:keys),
    \'s:PrintInfoProp(l:labels[v:val], task[v:val])',
  \)

  silent! bdelete KronosInfo
  silent! botright new KronosInfo

  call append(0, l:headers + l:keys)
  normal! ddgg

  setlocal filetype=kinfo
endfunction

"----------------------------------------------------------------------# Print #

" TODO ADD TESTS
function! kronos#ui#gui#PrintRow(type, row)
  let l:columns = s:CONST[a:type].COLUMN
  let l:widths = s:CONST[a:type].WIDTH

  return join(map(
    \copy(l:columns),
    \'s:PrintProp(a:row[v:val], l:widths[v:val])',
  \), '')[:78] . ' '
endfunction

" TODO ADD TESTS
function! kronos#ui#gui#PreparePrintTask(task)
  let l:task = copy(a:task)

  let l:task.tags = join(l:task.tags, ' ')
  let l:task.due = l:task.due ? l:task.due : ''
  let l:task.active = l:task.active ? l:task.active : ''
  let l:task.lastactive = l:task.lastactive ? l:task.lastactive : ''
  let l:task.worktime = l:task.worktime ? l:task.worktime : ''

  return l:task
endfunction

" TODO ADD TESTS
function! kronos#ui#gui#GetCurrentLineId()
  let l:idwidth = s:CONST.LIST.WIDTH.id
  return +getline('.')[:l:idwidth]
endfunction

"--------------------------------------------------------------------# Helpers #

function! s:PrintListHeader(_, row)
  return kronos#ui#gui#PrintRow('LIST', a:row)
endfunction

function! s:PrintListTask(_, task)
  let l:task = copy(kronos#ui#gui#PreparePrintTask(a:task))
  return kronos#ui#gui#PrintRow('LIST', l:task)
endfunction

function! s:PrintInfoHeader(_, row)
  return kronos#ui#gui#PrintRow('INFO', a:row)
endfunction

function! s:PrintInfoProp(key, value)
  let l:row = {'key': a:key, 'value': a:value}
  return kronos#ui#gui#PrintRow('INFO', l:row)
endfunction

function! s:PrintProp(prop, maxlen)
  let l:maxlen = a:maxlen - 2
  let l:proplen = strdisplaywidth(a:prop[:l:maxlen]) + 1

  return a:prop[:l:maxlen] . repeat(' ', a:maxlen - l:proplen) . '|'
endfunction

