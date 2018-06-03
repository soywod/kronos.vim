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
    return kronos#tool#logging#Error('Task [' . a:id . '] not found.')
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
  let l:choice =
    \ input('Do you really want to delete the task [' . a:id . '] ? (y/N)')

  if l:choice !~? '^y' | return | endif

  try
    call kronos#api#task#Delete(a:database, a:id)
    redraw
    echo 'Task [' . a:id . '] deleted.'
  catch 'task-not-found'
    return kronos#tool#logging#Error('Task [' . a:id . '] not found.')
  endtry
endfunction


"----------------------------------------------------------------------# Start #

function! kronos#ui#cli#Start(database, dateref, id)
  try
    let l:task = kronos#api#task#Read(a:database, a:id)
  catch 'task-not-found'
    return kronos#tool#logging#Error('Task [' . a:id . '] not found.')
  endtry

  if l:task.active
    return kronos#tool#logging#Error('Task [' . a:id . '] already active.')
  endif

  let l:task.active = a:dateref

  call kronos#api#task#Update(a:database, a:id, l:task)
endfunction

"-----------------------------------------------------------------------# Stop #

function! kronos#ui#cli#Stop(database, dateref, id)
  try
    let l:task = kronos#api#task#Read(a:database, a:id)
  catch 'task-not-found'
    return kronos#tool#logging#Error('Task [' . a:id . '] not found.')
  endtry

  if ! l:task.active
    return kronos#tool#logging#Error('Task [' . a:id . '] already stopped.')
  endif

  let l:task.worktime += (a:dateref - l:task.active)
  let l:task.active = 0
  let l:task.lastactive = a:dateref

  call kronos#api#task#Update(a:database, a:id, l:task)
endfunction

"-----------------------------------------------------------------------# Done #

function! kronos#ui#cli#Done(database, dateref, id)
  try
    let l:task = kronos#api#task#Read(a:database, a:id)
  catch 'task-not-found'
    return kronos#tool#logging#Error('Task [' . a:id . '] not found.')
  endtry

  if l:task.done
    return kronos#tool#logging#Error('Task [' . a:id . '] already done.')
  endif

  if l:task.active
    let l:task.worktime += (a:dateref - l:task.active)
    let l:task.active = 0
    let l:task.lastactive = a:dateref
  endif

  let l:task.done = a:dateref

  call kronos#api#task#Update(a:database, a:id, l:task)
endfunction

