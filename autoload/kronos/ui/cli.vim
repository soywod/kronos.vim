"------------------------------------------------------------------------# Add #

function! kronos#ui#cli#Add(database, dateref, args)
  let l:id = kronos#ui#common#Add(a:database, a:dateref, a:args)
  return kronos#tool#logging#Info('Task % added.', l:id)
endfunction

"-----------------------------------------------------------------------# Info #

function! kronos#ui#cli#Info(database, id)
  try
    let l:task = kronos#api#task#Read(a:database, a:id)

    for [l:key, l:value] in items(l:task)
      echo l:key . ': ' . string(l:value)
    endfor
  catch 'task-not-found'
    return kronos#tool#logging#Error('Task not found.')
  endtry
endfunction

"-----------------------------------------------------------------------# List #

function! kronos#ui#cli#List(database)
  let l:tasks = kronos#api#task#ReadAll(a:database)

  for l:task in l:tasks
    call kronos#tool#logging#Info('% ' . l:task.desc, l:task.id)
    echo ''
  endfor
endfunction

"---------------------------------------------------------------------# Update #

function! kronos#ui#cli#Update(database, dateref, args)
  try
    let l:id = kronos#ui#common#Update(a:database, a:dateref, a:args)
    return kronos#tool#logging#Info('Task % updated.', l:id)
  catch 'task-not-found'
    return kronos#tool#logging#Error('Task not found.')
  catch
    return kronos#tool#logging#Error('Impossible to update task.')
  endtry
endfunction

"---------------------------------------------------------------------# Delete #

function! kronos#ui#cli#Delete(database, id)
  try
    let l:choice =
      \input('Do you really want to delete the task [' . a:id . '] (y/N) ? ')
    if l:choice !~? '^y' | throw 'operation-canceled' | endif

    call kronos#ui#common#Delete(a:database, a:id)
    return kronos#tool#logging#Info('Task % deleted.', a:id)
  catch 'task-not-found'
    return kronos#tool#logging#Error('Task not found.')
  catch 'operation-canceled'
    return kronos#tool#logging#Error('Operation canceled.')
  catch
    return kronos#tool#logging#Error('Impossible to delete task.')
  endtry
endfunction

"----------------------------------------------------------------------# Start #

function! kronos#ui#cli#Start(database, dateref, id)
  try
    call kronos#ui#common#Start(a:database, a:dateref, a:id)
    return kronos#tool#logging#Info('Task % started.', a:id)
  catch 'task-not-found'
    return kronos#tool#logging#Error('Task not found.')
  catch 'task-already-active'
    return kronos#tool#logging#Error('Task already active.')
  endtry
endfunction

"-----------------------------------------------------------------------# Stop #

function! kronos#ui#cli#Stop(database, dateref, id)
  try
    call kronos#ui#common#Stop(a:database, a:dateref, a:id)
    return kronos#tool#logging#Info('Task % stopped.', a:id)
  catch 'task-not-found'
    return kronos#tool#logging#Error('Task not found.')
  catch 'task-already-stopped'
    return kronos#tool#logging#Error('Task already stopped.')
  endtry
endfunction

"---------------------------------------------------------------------# Toggle #

function! kronos#ui#cli#Toggle(database, dateref, id)
  try
    let l:task = kronos#api#task#Read(a:database, a:id)
  catch 'task-not-found'
    return kronos#tool#logging#Error('Task not found.')
  endtry

  if l:task.active
    return kronos#ui#cli#Stop(a:database, a:dateref, a:id)
  else
    return kronos#ui#cli#Start(a:database, a:dateref, a:id)
  endif
endfunction

"-----------------------------------------------------------------------# Done #

function! kronos#ui#cli#Done(database, dateref, id)
  try
    call kronos#ui#common#Done(a:database, a:dateref, a:id)
    return kronos#tool#logging#Info('Task % done.', a:id)
  catch 'task-not-found'
    return kronos#tool#logging#Error('Task not found.')
  catch 'task-already-done'
    return kronos#tool#logging#Error('Task already done.')
  endtry
endfunction

"-------------------------------------------------------------------# Worktime #

function! kronos#ui#cli#Worktime(database, dateref, args)
  let  worktime = kronos#ui#common#Worktime(a:database, a:dateref, a:args)
  echo kronos#tool#datetime#PrintInterval(worktime)
endfunction

