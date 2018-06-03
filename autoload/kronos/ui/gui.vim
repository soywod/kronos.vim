"------------------------------------------------------------------------# Add #

function! kronos#ui#gui#Add(database, dateref)
  try
    let l:args = input('New task string: ')
    let l:id = kronos#ui#common#Add(a:database, a:dateref, l:args)
  catch
    return kronos#tool#logging#Error('Impossible to add task.')
  endtry

  call kronos#tool#logging#Info('Task % added.', l:id)
  call kronos#ui#gui#Open(a:database)
endfunction

"---------------------------------------------------------------------# Delete #

function! kronos#ui#gui#Delete(database)
  try
    let l:idwidth = kronos#GetConfig().gui.width.id
    let l:id = +getline('.')[:l:idwidth]
    call kronos#ui#common#Delete(a:database, l:id)
  catch 'task-not-found'
    return kronos#tool#logging#Error('Task [' . l:id . '] not found.')
  catch 'operation-canceled'
    return kronos#tool#logging#Error('Operation canceled.')
  catch
    return kronos#tool#logging#Error('Impossible to delete task [' . l:id . '].')
  endtry

  call kronos#tool#logging#Info('Task % deleted.', l:id)
  call kronos#ui#gui#Open(a:database)
endfunction

"-----------------------------------------------------------------------# Open #

function! kronos#ui#gui#Open(database)
  let l:headers = [copy(kronos#GetConfig().gui.label)]
  let l:tasks = copy(kronos#api#task#ReadAll(a:database))

  call map(l:headers, function('s:HeaderToString'))
  call map(l:tasks, function('s:TaskToString'))

  silent! bdelete Kronos
  silent! new Kronos

  call append(0, l:headers + l:tasks)
  normal! dd2G

  setlocal filetype=kronos
endfunction

"-------------------------------------------------------------------# ToString #

function! kronos#ui#gui#ToString(task)
  let l:config = copy(kronos#GetConfig().gui)

  return join(map(
    \l:config.order,
    \'s:TaskPropToString(a:task[v:val], l:config.width[v:val])',
  \), '')
endfunction

"--------------------------------------------------------------------# Helpers #

function! s:HeaderToString(_, header)
  return kronos#ui#gui#ToString(a:header)
endfunction

function! s:TaskToString(_, task)
  let l:task = copy(a:task)

  let l:task.id = string(l:task.id)
  let l:task.desc = l:task.desc
  let l:task.tags = join(l:task.tags, ' ')
  let l:task.due = l:task.due ? l:task.due : ''
  let l:task.active = l:task.active ? l:task.active : ''

  return kronos#ui#gui#ToString(l:task)
endfunction

function! s:TaskPropToString(prop, maxlen)
  let l:maxlen = a:maxlen - 2
  let l:proplen = strdisplaywidth(a:prop[:l:maxlen])

  return a:prop[:l:maxlen] . repeat(' ', a:maxlen - l:proplen)
endfunction

