" ---------------------------------------------------------------- # Constants #

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

function! kronos#gui#Const()
  return s:CONST
endfunction

" ---------------------------------------------------------------------- # Add #

function! kronos#gui#Add()
  try
    let args = input('New task string (:h kronos-add): ')
    if  empty(args) | throw 'operation-canceled' | endif

    call kronos#core#ui#Add(g:kronos_database, localtime(), args)
  catch 'operation-canceled'
    return kronos#tool#log#Error('Operation canceled.')
  catch
    return kronos#tool#log#Error('Error while adding new task.')
  endtry

  call kronos#gui#List()
endfunction

" --------------------------------------------------------------------- # Info #

function! kronos#gui#Info()
  let id = GetFocusedTaskId()

  let columns = s:CONST.INFO.COLUMN
  let keys    = s:CONST.INFO.KEY
  let labels  = s:CONST.LABEL

  let headers = [filter(copy(s:CONST.LABEL), 'index(columns, v:key) + 1')]
  let headers = map(copy(headers), function('PrintInfoHeader'))

  try
    let task = kronos#core#task#Read(g:kronos_database, id)
  catch 'task-not-found'
    return kronos#tool#log#Error('Task not found.')
  catch
    return kronos#tool#log#Error('Error while reading task.')
  endtry

  let task = kronos#tool#task#ToInfoString(task)
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

" --------------------------------------------------------------------- # List #

function! kronos#gui#List()
  let columns = s:CONST.LIST.COLUMN
  let headers = [filter(copy(s:CONST.LABEL), 'index(columns, v:key) + 1')]
  let prevpos = getpos('.')
  let tasks = kronos#core#ui#List(g:kronos_database)

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

" ------------------------------------------------------------------- # Update #

function! kronos#gui#Update()
  try
    let args = input('Update task string (:h kronos-add): ')
    if  empty(args) | throw 'operation-canceled' | endif

    let args = join([GetFocusedTaskId(), args], ' ')

    call kronos#core#ui#Update(g:kronos_database, localtime(), args)
  catch 'operation-canceled'
    return kronos#tool#log#Error('Operation canceled.')
  catch 'task-not-found'
    return kronos#tool#log#Error('Task not found.')
  catch
    return kronos#tool#log#Error('Error while updating task.')
  endtry

  call kronos#gui#List()
endfunction

" ------------------------------------------------------------------- # Delete #

function! kronos#gui#Delete()
  try
    let id = GetFocusedTaskId()
    call kronos#core#ui#Delete(g:kronos_database, id)
  catch 'task-not-found'
    return kronos#tool#log#Error('Task not found.')
  catch 'operation-canceled'
    return kronos#tool#log#Error('Operation canceled.')
  catch
    return kronos#tool#log#Error('Error while deleting task.')
  endtry

  call kronos#gui#List()
endfunction

" -------------------------------------------------------------------- # Start #

function! kronos#gui#Start()
  try
    let id = GetFocusedTaskId()
    call kronos#core#ui#Start(g:kronos_database, localtime(), id)
  catch 'task-not-found'
    return kronos#tool#log#Error('Task not found.')
  catch 'task-already-active'
    return kronos#tool#log#Error('Task already active.')
  catch
    return kronos#tool#log#Error('Error while starting task.')
  endtry

  call kronos#gui#List()
endfunction

" --------------------------------------------------------------------- # Stop #

function! kronos#gui#Stop()
  try
    let id = GetFocusedTaskId()
    call kronos#core#ui#Stop(g:kronos_database, localtime(), id)
  catch 'task-not-found'
    return kronos#tool#log#Error('Task not found.')
  catch 'task-already-stopped'
    return kronos#tool#log#Error('Task already stopped.')
  catch
    return kronos#tool#log#Error('Error while stopping task.')
  endtry

  call kronos#gui#List()
endfunction

" ------------------------------------------------------------------- # Toggle #

function! kronos#gui#Toggle()
  try
    let id   = GetFocusedTaskId()
    let task = kronos#core#task#Read(g:kronos_database, id)
  catch 'task-not-found'
    return kronos#tool#log#Error('Task not found.')
  catch
    return kronos#tool#log#Error('Error while reading task.')
  endtry

  return task.active
    \? kronos#gui#Stop()
    \: kronos#gui#Start()
endfunction

" --------------------------------------------------------------------- # Done #

function! kronos#gui#Done()
  try
    let id = GetFocusedTaskId()
    call kronos#core#ui#Done(g:kronos_database, localtime(), id)
  catch 'task-not-found'
    return kronos#tool#log#Error('Task not found.')
  catch 'task-already-done'
    return kronos#tool#log#Error('Task already done.')
  catch
    return kronos#tool#log#Error('Error while marking task as done.')
  endtry

  call kronos#gui#List()
endfunction

" ------------------------------------------------------------------- # Undone #

function! kronos#gui#Undone()
  try
    let id = GetFocusedTaskId()
    call kronos#core#ui#Undone(g:kronos_database, id)
  catch 'task-not-found'
    return kronos#tool#log#Error('Task not found.')
  catch 'task-not-done'
    return kronos#tool#log#Error('Task not done.')
  catch
    return kronos#tool#log#Error('Error while marking task as undone.')
  endtry

  call kronos#gui#List()
endfunction

" ------------------------------------------------------------------ # Context #

function! kronos#gui#Context()
  try
    let args = input('Context (:h kronos-context): ')
    call kronos#core#ui#Context(args)
  catch
    return kronos#tool#log#Error('Error while setting context.')
  endtry

  call kronos#gui#List()
endfunction

" --------------------------------------------------------- # Toggle hide done #

function! kronos#gui#ToggleHideDone()
  let g:kronos_hide_done = ! g:kronos_hide_done
  call kronos#gui#List()
endfunction

" -------------------------------------------------------------------- # Print #

function! kronos#gui#PrintRow(type, row)
  let columns = s:CONST[a:type].COLUMN
  let widths  = s:CONST[a:type].WIDTH

  return join(map(
    \copy(columns),
    \'PrintProp(a:row[v:val], widths[v:val])',
  \), '')[:78] . ' '
endfunction

" ------------------------------------------------------------------ # Helpers #

function! PrintListHeader(_, row)
  return kronos#gui#PrintRow('LIST', a:row)
endfunction

function! PrintListTask(_, task)
  let task = copy(kronos#tool#task#ToListString(a:task))
  return kronos#gui#PrintRow('LIST', task)
endfunction

function! PrintInfoHeader(_, row)
  return kronos#gui#PrintRow('INFO', a:row)
endfunction

function! PrintInfoProp(key, value)
  let row = {'key': a:key, 'value': a:value}
  return kronos#gui#PrintRow('INFO', row)
endfunction

function! PrintProp(prop, maxlen)
  let maxlen = a:maxlen - 2
  let proplen = strdisplaywidth(a:prop[:maxlen]) + 1

  return a:prop[:maxlen] . repeat(' ', a:maxlen - proplen) . '|'
endfunction

function! GetFocusedTaskId()
  let tasks = kronos#core#task#ReadAll(g:kronos_database)
  let index = line('.') - 2
  if  index == -1 | throw 'task-not-found' | endif

  return get(tasks, index).id
endfunction

