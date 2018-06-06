"------------------------------------------------------------------# Constants #

let s:CONST = {
  \'INFO': {
    \'COLUMN': ['key', 'value'],
    \'KEY': ['id', 'desc', 'tags', 'active', 'lastactive', 'due', 'worktime', 'done'],
    \'WIDTH': {
      \'key'  : 15,
      \'value': 65,
    \},
  \},
  \'LABEL': {
    \'active'    : 'ACTIVE',
    \'desc'      : 'DESC',
    \'done'      : 'DONE',
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

function! kronos#ui#gui#Add()
  try
    let args = input('New task string: ')
    let id   = kronos#ui#common#Add(g:kronos_database, localtime(), args)
    call kronos#tool#logging#Info('Task % added.', id)
  catch
    return kronos#tool#logging#Error('Impossible to add task.')
  endtry

  return kronos#ui#gui#ShowList()
endfunction

"---------------------------------------------------------------------# Update #

function! kronos#ui#gui#Update()
  try
    let id   = GetFocusedTaskId()
    let args = id . ' ' . input('Update task string: ')
    call kronos#ui#common#Update(g:kronos_database, localtime(), args)
    call kronos#tool#logging#Info('Task % updated.', id)
  catch 'task-not-found'
    return kronos#tool#logging#Error('Task not found.')
  catch
    return kronos#tool#logging#Error('Impossible to update task.')
  endtry

  return kronos#ui#gui#ShowList()
endfunction

"-----------------------------------------------------------------------# Info #

function! kronos#ui#gui#Info()
  try
    let id = GetFocusedTaskId()
    return kronos#ui#gui#ShowInfo(id)
  catch 'task-not-found'
    return kronos#tool#logging#Error('Task not found.')
  catch
    return kronos#tool#logging#Error('Impossible to show task info.')
  endtry
endfunction

"---------------------------------------------------------------------# Delete #

function! kronos#ui#gui#Delete()
  try
    let id = GetFocusedTaskId()

    let choice =
      \input('Do you really want to delete the task [' . id . '] (y/N) ? ')
    if  choice !~? '^y' | throw 'operation-canceled' | endif

    call kronos#ui#common#Delete(g:kronos_database, id)
    call kronos#tool#logging#Info('Task % deleted.', id)
  catch 'task-not-found'
    return kronos#tool#logging#Error('Task not found.')
  catch 'operation-canceled'
    return kronos#tool#logging#Error('Operation canceled.')
  catch
    return kronos#tool#logging#Error('Impossible to delete task.')
  endtry

  return kronos#ui#gui#ShowList()
endfunction

"----------------------------------------------------------------------# Start #

function! kronos#ui#gui#Start()
  try
    let id = GetFocusedTaskId()
    call kronos#ui#common#Start(g:kronos_database, localtime(), id)
    call kronos#tool#logging#Info('Task % started.', id)
  catch 'task-not-found'
    return kronos#tool#logging#Error('Task not found.')
  catch 'task-already-active'
    return kronos#tool#logging#Error('Task already active.')
  endtry

  return kronos#ui#gui#ShowList()
endfunction

"-----------------------------------------------------------------------# Stop #

function! kronos#ui#gui#Stop()
  try
    let id = GetFocusedTaskId()
    call kronos#ui#common#Stop(g:kronos_database, localtime(), id)
    call kronos#tool#logging#Info('Task % stopped.', id)
  catch 'task-not-found'
    return kronos#tool#logging#Error('Task not found.')
  catch 'task-already-stopped'
    return kronos#tool#logging#Error('Task already stopped.')
  endtry

  return kronos#ui#gui#ShowList()
endfunction

"---------------------------------------------------------------------# Toggle #

function! kronos#ui#gui#Toggle()
  try
    let id   = GetFocusedTaskId()
    let task = kronos#api#task#Read(g:kronos_database, id)
  catch 'task-not-found'
    return kronos#tool#logging#Error('Task not found.')
  endtry

  if task.active
    return kronos#ui#gui#Stop()
  else
    return kronos#ui#gui#Start()
  endif
endfunction

"-----------------------------------------------------------------------# Done #

function! kronos#ui#gui#Done()
  try
    let id = GetFocusedTaskId()
    call kronos#ui#common#Done(g:kronos_database, localtime(), id)
    call kronos#tool#logging#Info('Task % done.', id)
  catch 'task-not-found'
    return kronos#tool#logging#Error('Task not found.')
  catch 'operation-canceled'
    return kronos#tool#logging#Error('Operation canceled.')
  catch 'task-already-done'
    return kronos#tool#logging#Error('Task already done.')
  endtry

  return kronos#ui#gui#ShowList()
endfunction

"------------------------------------------------------------------# Show list #

function! kronos#ui#gui#ShowList()
  let columns = s:CONST.LIST.COLUMN
  let headers = [filter(copy(s:CONST.LABEL), 'index(columns, v:key) + 1')]
  let prevpos = getpos('.')
  let tasks   = kronos#api#task#ReadAll(g:kronos_database)

  let headers = map(copy(headers), function('PrintListHeader'))
  let tasks   = map(copy(tasks), function('PrintListTask'))

  redir => buflist | silent! ls | redir END
  silent! edit Kronos

  if match(buflist, '"Kronos"') + 1
    setlocal modifiable
    execute '0,$d'
  endif

  call append(0, headers + tasks)
  execute '$d'
  call setpos('.', prevpos)
  setlocal filetype=klist
endfunction

"------------------------------------------------------------------# Show info #

function! kronos#ui#gui#ShowInfo(id)
  let columns = s:CONST.INFO.COLUMN
  let keys    = s:CONST.INFO.KEY
  let labels  = s:CONST.LABEL

  let headers = [filter(copy(s:CONST.LABEL), 'index(columns, v:key) + 1')]
  let headers = map(copy(headers), function('PrintInfoHeader'))

  let task = kronos#api#task#Read(g:kronos_database, a:id)
  let task = kronos#ui#gui#FormatTaskForInfo(task)

  let keys = map(
    \copy(keys),
    \'PrintInfoProp(labels[v:val], task[v:val])',
  \)

  silent! bdelete KronosInfo
  silent! botright new KronosInfo

  call append(0, headers + keys)
  normal! ddgg

  setlocal filetype=kinfo
endfunction

"----------------------------------------------------------------------# Print #

function! kronos#ui#gui#PrintRow(type, row)
  let columns = s:CONST[a:type].COLUMN
  let widths = s:CONST[a:type].WIDTH

  return join(map(
    \copy(columns),
    \'PrintProp(a:row[v:val], widths[v:val])',
  \), '')[:78] . ' '
endfunction

"-------------------------------------------------------# Format task for list #

function! kronos#ui#gui#FormatTaskForList(task)
  let DateDiff = function('kronos#tool#datetime#GetHumanDiff', [localtime()])

  let task      = copy(a:task)
  let task.id   = task.done ? '-' : task.id
  let task.tags = join(task.tags, ' ')

  let task.active     = task.active     ? DateDiff(task.active)    : ''
  let task.done       = task.done       ? DateDiff(task.done)      : ''
  let task.due        = task.due        ? DateDiff(task.due)       : ''
  let task.lastactive = task.lastactive ? DateDiff(task.lastactive): ''
  let task.worktime   = task.worktime   ? task.worktime            : ''

  return task
endfunction

"-------------------------------------------------------# Format task for info #

function! kronos#ui#gui#FormatTaskForInfo(task)
  let Date = function('kronos#tool#datetime#GetHumanDate')

  let task      = copy(a:task)
  let task.tags = join(task.tags, ' ')

  let task.active     = task.active     ? Date(task.active)    : ''
  let task.done       = task.done       ? Date(task.done)      : ''
  let task.due        = task.due        ? Date(task.due)       : ''
  let task.lastactive = task.lastactive ? Date(task.lastactive): ''
  let task.worktime   = task.worktime   ? task.worktime        : ''

  return task
endfunction

"--------------------------------------------------------------------# Helpers #

function! PrintListHeader(_, row)
  return kronos#ui#gui#PrintRow('LIST', a:row)
endfunction

function! PrintListTask(_, task)
  let FormatTask = function('kronos#ui#gui#FormatTaskForList')
  let PrintTask  = function('kronos#ui#gui#PrintRow', ['LIST'])

  let task = copy(FormatTask(a:task))
  return PrintTask(task)
endfunction

function! PrintInfoHeader(_, row)
  return kronos#ui#gui#PrintRow('INFO', a:row)
endfunction

function! PrintInfoProp(key, value)
  let row = {'key': a:key, 'value': a:value}
  return kronos#ui#gui#PrintRow('INFO', row)
endfunction

function! PrintProp(prop, maxlen)
  let maxlen = a:maxlen - 2
  let proplen = strdisplaywidth(a:prop[:maxlen]) + 1

  return a:prop[:maxlen] . repeat(' ', a:maxlen - proplen) . '|'
endfunction

function! GetFocusedTaskId()
  let tasks = kronos#api#task#ReadAll(g:kronos_database)
  let index = line('.') - 2
  if  index == -1 | throw 'task-not-found' | endif

  return get(tasks, index).id
endfunction

