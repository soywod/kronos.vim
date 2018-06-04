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

"-----------------------------------------------------------------------# Info #

function! kronos#ui#gui#Info(database)
  try
    let l:id = s:GetCurrentLineId()
    call kronos#ui#gui#OpenInfo(a:database, l:id)
  catch 'task-not-found'
    return kronos#tool#logging#Error('Task [' . l:id . '] not found.')
  catch
    return kronos#tool#logging#Error('Impossible to show task info.')
  endtry
endfunction

"---------------------------------------------------------------------# Delete #

function! kronos#ui#gui#Delete(database)
  try
    let l:id = s:GetCurrentLineId()
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

"------------------------------------------------------------------# Open Info #

function! kronos#ui#gui#OpenInfo(database, id)
  let l:task = kronos#api#task#Read(a:database, a:id)
  let l:bsize = winwidth(0) - &foldcolumn - 81

  silent! bdelete KronosInfo
  execute 'silent! ' . l:bsize . 'vnew KronosInfo'

  call append(0, kronos#ui#gui#ToKronosInfoString(l:task))
  normal! ddgg

  setlocal filetype=kronosinfo
endfunction

"-------------------------------------------------------------# ToKronosString #

function! kronos#ui#gui#ToKronosString(task)
  let l:config = copy(kronos#GetConfig().gui)

  return join(map(
    \l:config.order,
    \'s:TaskPropToString(a:task[v:val], l:config.width[v:val])',
  \), '')
endfunction

"---------------------------------------------------------# ToKronosInfoString #

function! kronos#ui#gui#ToKronosInfoString(task)
  let l:task = copy(a:task)

  let l:task.id = string(l:task.id)
  let l:task.desc = l:task.desc
  let l:task.tags = join(l:task.tags, ' ')
  let l:task.due = l:task.due ? l:task.due : ''
  let l:task.active = l:task.active ? l:task.active : ''

  return [
    \'      ID ' . l:task.id,
    \'    DESC ' . l:task.desc,
    \'    TAGS ' . l:task.tags,
    \'  ACTIVE ' . l:task.active,
    \'     DUE ' . l:task.due,
    \'WORKTIME ' . l:task.worktime,
  \]
endfunction

"--------------------------------------------------------------------# Helpers #

function! s:HeaderToString(_, header)
  return kronos#ui#gui#ToKronosString(a:header)
endfunction

function! s:TaskToString(_, task)
  let l:task = copy(a:task)

  let l:task.id = string(l:task.id)
  let l:task.desc = l:task.desc
  let l:task.tags = join(l:task.tags, ' ')
  let l:task.due = l:task.due ? l:task.due : ''
  let l:task.active = l:task.active ? l:task.active : ''

  return kronos#ui#gui#ToKronosString(l:task)
endfunction

function! s:TaskPropToString(prop, maxlen)
  let l:maxlen = a:maxlen - 2
  let l:proplen = strdisplaywidth(a:prop[:l:maxlen])

  return a:prop[:l:maxlen] . repeat(' ', a:maxlen - l:proplen)
endfunction

function! s:GetCurrentLineId()
  let l:idwidth = kronos#GetConfig().gui.width.id
  return +getline('.')[:l:idwidth]
endfunction

