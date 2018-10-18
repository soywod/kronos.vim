" ------------------------------------------------------------------- # Config #

let s:config = {
  \'info': {
    \'column': ['key', 'value'],
    \'key': ['id', 'desc', 'tags', 'active', 'last_active', 'due', 'worktime', 'done'],
    \'width': {
      \'key'  : 15,
      \'value': 65,
    \},
  \},
  \'list': {
    \'column': ['id', 'desc', 'tags', 'active', 'due'],
    \'width': {
      \'active': 13,
      \'desc': 29,
      \'due': 13,
      \'id': 5,
      \'tags': 20,
    \},
  \},
  \'label': {
    \'active': 'ACTIVE',
    \'desc': 'DESC',
    \'done': 'DONE',
    \'due': 'DUE',
    \'id': 'ID',
    \'key': 'KEY',
    \'last_active': 'LAST ACTIVE',
    \'tags': 'TAGS',
    \'value': 'VALUE',
    \'worktime': 'WORKTIME',
  \},
\}

function! kronos#interface#gui#config()
  return s:config
endfunction

" ---------------------------------------------------------------------- # Add #

function! kronos#interface#gui#add()
  try
    let args = input('New task string (:h kronos-add): ')
    if  empty(args) | throw 'operation-canceled' | endif

    call kronos#interface#common#add(g:kronos_database, localtime(), args)
  catch 'operation-canceled'
    return kronos#utils#log#error('Operation canceled.')
  catch
    return kronos#utils#log#error('Error while adding new task.')
  endtry

  call kronos#interface#gui#list()
endfunction

" --------------------------------------------------------------------- # Info #

function! kronos#interface#gui#info()
  let id = s:get_focused_task_id()

  let columns = s:config.info.column
  let keys    = s:config.info.key
  let labels  = s:config.label

  let headers = [filter(copy(s:config.label), 'index(columns, v:key) + 1')]
  let headers = map(copy(headers), function('s:print_info_header'))

  try
    let task = kronos#task#read(g:kronos_database, id)
  catch 'task-not-found'
    return kronos#utils#log#error('Task not found.')
  catch
    return kronos#utils#log#error('Error while reading task.')
  endtry

  let task = kronos#task#to_info_string(task)
  let keys = map(
    \copy(keys),
    \'s:print_info_prop(labels[v:val], task[v:val])',
  \)

  silent! bdelete KronosInfo
  silent! botright new KronosInfo

  call append(0, headers + keys)
  normal! ddgg
  setlocal filetype=kinfo
endfunction

" --------------------------------------------------------------------- # List #

function! kronos#interface#gui#list()
  let columns = s:config.list.column
  let headers = [filter(copy(s:config.label), 'index(columns, v:key) + 1')]
  let prevpos = getpos('.')
  let tasks = kronos#interface#common#list(g:kronos_database)

  let headers = map(copy(headers), function('s:print_list_header'))
  let tasks   = map(copy(tasks), function('s:print_list_task'))

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

function! kronos#interface#gui#update()
  try
    let args = input('Update task string (:h kronos-add): ')
    if  empty(args) | throw 'operation-canceled' | endif

    let args = join([s:get_focused_task_id(), args], ' ')

    call kronos#interface#common#update(g:kronos_database, localtime(), args)
  catch 'operation-canceled'
    return kronos#utils#log#error('Operation canceled.')
  catch 'task-not-found'
    return kronos#utils#log#error('Task not found.')
  " catch
  "   return kronos#utils#log#error('Error while updating task.')
  endtry

  call kronos#interface#gui#list()
endfunction

" ------------------------------------------------------------------- # Delete #

function! kronos#interface#gui#delete()
  try
    let id = s:get_focused_task_id()
    call kronos#interface#common#delete(g:kronos_database, id)
  catch 'task-not-found'
    return kronos#utils#log#error('Task not found.')
  catch 'operation-canceled'
    return kronos#utils#log#error('Operation canceled.')
  catch
    return kronos#utils#log#error('Error while deleting task.')
  endtry

  call kronos#interface#gui#list()
endfunction

" -------------------------------------------------------------------- # Start #

function! kronos#interface#gui#start()
  try
    let id = s:get_focused_task_id()
    call kronos#interface#common#start(g:kronos_database, localtime(), id)
  catch 'task-not-found'
    return kronos#utils#log#error('Task not found.')
  catch 'task-already-active'
    return kronos#utils#log#error('Task already active.')
  catch
    return kronos#utils#log#error('Error while starting task.')
  endtry

  call kronos#interface#gui#list()
endfunction

" --------------------------------------------------------------------- # Stop #

function! kronos#interface#gui#stop()
  try
    let id = s:get_focused_task_id()
    call kronos#interface#common#stop(g:kronos_database, localtime(), id)
  catch 'task-not-found'
    return kronos#utils#log#error('Task not found.')
  catch 'task-already-stopped'
    return kronos#utils#log#error('Task already stopped.')
  catch
    return kronos#utils#log#error('Error while stopping task.')
  endtry

  call kronos#interface#gui#list()
endfunction

" ------------------------------------------------------------------- # Toggle #

function! kronos#interface#gui#toggle()
  try
    let id   = s:get_focused_task_id()
    let task = kronos#task#read(g:kronos_database, id)
  catch 'task-not-found'
    return kronos#utils#log#error('Task not found.')
  catch
    return kronos#utils#log#error('Error while reading task.')
  endtry

  return task.active
    \? kronos#interface#gui#stop()
    \: kronos#interface#gui#start()
endfunction

" --------------------------------------------------------------------- # Done #

function! kronos#interface#gui#done()
  try
    let id = s:get_focused_task_id()
    call kronos#interface#common#done(g:kronos_database, localtime(), id)
  catch 'task-not-found'
    return kronos#utils#log#error('Task not found.')
  catch 'task-already-done'
    return kronos#utils#log#error('Task already done.')
  catch
    return kronos#utils#log#error('Error while marking task as done.')
  endtry

  call kronos#interface#gui#list()
endfunction

" ------------------------------------------------------------------- # Undone #

function! kronos#interface#gui#undone()
  try
    let id = s:get_focused_task_id()
    call kronos#interface#common#undone(g:kronos_database, id)
  catch 'task-not-found'
    return kronos#utils#log#error('Task not found.')
  catch 'task-not-done'
    return kronos#utils#log#error('Task not done.')
  catch
    return kronos#utils#log#error('Error while marking task as undone.')
  endtry

  call kronos#interface#gui#list()
endfunction

" ------------------------------------------------------------------ # Context #

function! kronos#interface#gui#context()
  try
    let args = input('Context (:h kronos-context): ')
    call kronos#interface#common#context(args)
  catch
    return kronos#utils#log#error('Error while setting context.')
  endtry

  call kronos#interface#gui#list()
endfunction

" --------------------------------------------------------- # Toggle hide done #

function! kronos#interface#gui#toggle_hide_done()
  let g:kronos_hide_done = ! g:kronos_hide_done
  call kronos#interface#gui#list()
endfunction

" -------------------------------------------------------------------- # Print #

function! kronos#interface#gui#print_row(type, row)
  let columns = s:config[a:type].column
  let widths  = s:config[a:type].width

  return join(map(
    \copy(columns),
    \'s:print_prop(a:row[v:val], widths[v:val])',
  \), '')[:78] . ' '
endfunction

" -------------------------------------------------------------------- # Utils #

function! s:print_list_header(_, row)
  return kronos#interface#gui#print_row('list', a:row)
endfunction

function! s:print_list_task(_, task)
  let task = copy(kronos#task#to_list_string(a:task))
  return kronos#interface#gui#print_row('list', task)
endfunction

function! s:print_info_header(_, row)
  return kronos#interface#gui#print_row('info', a:row)
endfunction

function! s:print_info_prop(key, value)
  let row = {'key': a:key, 'value': a:value}
  return kronos#interface#gui#print_row('info', row)
endfunction

function! s:print_prop(prop, maxlen)
  let maxlen = a:maxlen - 2
  let proplen = strdisplaywidth(a:prop[:maxlen]) + 1

  return a:prop[:maxlen] . repeat(' ', a:maxlen - proplen) . '|'
endfunction

function! s:get_focused_task_id()
  let tasks = kronos#task#read_all(g:kronos_database)
  let index = line('.') - 2
  if  index == -1 | throw 'task-not-found' | endif

  return +get(tasks, index).id
endfunction
