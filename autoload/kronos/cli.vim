" ---------------------------------------------------------------------- # Add #

function! kronos#cli#Add(args)
  try
    call kronos#core#ui#Add(g:kronos_database, localtime(), a:args)
  catch
    return kronos#tool#log#Error('Error while adding new task.')
  endtry
endfunction

" --------------------------------------------------------------------- # Info #

function! kronos#cli#Info(id)
  try
    let task = kronos#core#task#Read(g:kronos_database, a:id)
    let task = kronos#tool#task#ToInfoString(task)
    let maxkeylen = max(map(copy(keys(task)), 'strdisplaywidth(v:val)'))

    for key in kronos#gui#Const().INFO.KEY
      let value   = string(task[key])
      let spaces  = repeat(' ', maxkeylen - strdisplaywidth(key))
      let message = key . spaces . ': ' . value

      call kronos#tool#log#Info(message)
    endfor
  catch 'task-not-found'
    return kronos#tool#log#Error('Task not found.')
  catch
    return kronos#tool#log#Error('Error while showing task info.')
  endtry
endfunction

" --------------------------------------------------------------------- # List #

function! kronos#cli#List(args)
  try
    let tasks = kronos#core#task#ReadAll(g:kronos_database)

    if (g:kronos_hide_done)
      let tasks = filter(copy(tasks), 'v:val.done == 0')
    endif

    let maxkeylen = max(map(copy(tasks), 'strdisplaywidth(v:val.id)'))

    for task in tasks
      let spaces  = repeat(' ', maxkeylen - strdisplaywidth(task.id))
      let message = '[' . task.id . ']' . spaces . ': ' . task.desc

      call kronos#tool#log#Info(message)
    endfor
  catch
    return kronos#tool#log#Error('Error while showing tasks list.')
  endtry
endfunction

" ------------------------------------------------------------------- # Update #

function! kronos#cli#Update(args)
  try
    call kronos#core#ui#Update(g:kronos_database, localtime(), a:args)
  catch 'task-not-found'
    return kronos#tool#log#Error('Task not found.')
  catch
    return kronos#tool#log#Error('Error while updating task.')
  endtry
endfunction

" ------------------------------------------------------------------- # Delete #

function! kronos#cli#Delete(id)
  try
    call kronos#core#ui#Delete(g:kronos_database, a:id)
  catch 'task-not-found'
    return kronos#tool#log#Error('Task not found.')
  catch 'operation-canceled'
    return kronos#tool#log#Error('Operation canceled.')
  catch
    return kronos#tool#log#Error('Error while deleting task.')
  endtry
endfunction

" -------------------------------------------------------------------- # Start #

function! kronos#cli#Start(id)
  try
    call kronos#core#ui#Start(g:kronos_database, localtime(), a:id)
  catch 'task-not-found'
    return kronos#tool#log#Error('Task not found.')
  catch 'task-already-active'
    return kronos#tool#log#Error('Task already active.')
  catch
    return kronos#tool#log#Error('Error while starting task.')
  endtry
endfunction

" --------------------------------------------------------------------- # Stop #

function! kronos#cli#Stop(id)
  try
    call kronos#core#ui#Stop(g:kronos_database, localtime(), a:id)
  catch 'task-not-found'
    return kronos#tool#log#Error('Task not found.')
  catch 'task-already-stopped'
    return kronos#tool#log#Error('Task already stopped.')
  catch
    return kronos#tool#log#Error('Error while stopping task.')
  endtry
endfunction

" ------------------------------------------------------------------- # Toggle #

function! kronos#cli#Toggle(id)
  try
    let task = kronos#core#task#Read(g:kronos_database, a:id)
  catch 'task-not-found'
    return kronos#tool#log#Error('Task not found.')
  catch
    return kronos#tool#log#Error('Error while reading task.')
  endtry

  return task.active
    \? kronos#cli#Stop(a:id)
    \: kronos#cli#Start(a:id)
endfunction

" --------------------------------------------------------------------- # Done #

function! kronos#cli#Done(id)
  try
    call kronos#core#ui#Done(g:kronos_database, localtime(), a:id)
  catch 'task-not-found'
    return kronos#tool#log#Error('Task not found.')
  catch 'task-already-done'
    return kronos#tool#log#Error('Task already done.')
  catch
    return kronos#tool#log#Error('Error while marking task as done.')
  endtry
endfunction

" ----------------------------------------------------------------- # Worktime #

function! kronos#cli#Worktime(args)
  let worktime = kronos#core#ui#Worktime(g:kronos_database, localtime(), a:args)
  let message  = kronos#tool#datetime#PrintInterval(worktime)

  call kronos#tool#log#Info(message)
endfunction

