"------------------------------------------------------------------------# Add #

function! kronos#ui#cli#Add(database, dateref, args)
  let l:id = kronos#ui#common#Add(a:database, a:dateref, a:args)
  echo 'Task [' . l:id . '] added.'
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
    echo '[' . l:task.id . '] ' . l:task.desc
  endfor
endfunction

"---------------------------------------------------------------------# Update #

function! kronos#ui#cli#Update(database, dateref, args)
  try
    let l:id = kronos#ui#common#Update(a:database, a:dateref, a:args)
  catch 'task-not-found'
    return kronos#tool#logging#Error('Task not found.')
  catch
    let l:msg = 'Not enough arguments. Usage: KronosUpdate <id> <args>.'
    return kronos#tool#logging#Error(l:msg)
  endtry

  echo 'Task [' . l:id . '] updated.'
endfunction

"---------------------------------------------------------------------# Delete #

function! kronos#ui#cli#Delete(database, id)
  try
    call kronos#ui#common#Delete(a:database, a:id)
    call kronos#tool#logging#Info('Task % deleted.', a:id)
  catch 'task-not-found'
    call kronos#tool#logging#Error('Task not found.')
  catch
    call kronos#tool#logging#Error('Impossible to delete task.')
  endtry
endfunction

"----------------------------------------------------------------------# Start #

function! kronos#ui#cli#Start(database, dateref, id)
  try
    call kronos#ui#common#Start(a:database, a:dateref, a:id)
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
  catch 'task-not-found'
    return kronos#tool#logging#Error('Task not found.')
  catch 'task-already-stopped'
    return kronos#tool#logging#Error('Task already stopped.')
  endtry
endfunction

"-----------------------------------------------------------------------# Done #

function! kronos#ui#cli#Done(database, dateref, id)
  try
    call kronos#ui#common#Done(a:database, a:dateref, a:id)
  catch 'task-not-found'
    return kronos#tool#logging#Error('Task not found.')
  catch 'task-already-done'
    return kronos#tool#logging#Error('Task already done.')
  endtry
endfunction

