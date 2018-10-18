" ---------------------------------------------------------------------- # Add #

function! kronos#interface#cli#add(args)
  try
    call kronos#interface#common#add(g:kronos_database, localtime(), a:args)
  catch
    return kronos#utils#log#error('Error while adding new task.')
  endtry
endfunction

" --------------------------------------------------------------------- # Info #

function! kronos#interface#cli#info(id)
  try
    let task = kronos#task#read(g:kronos_database, a:id)
    let task = kronos#task#to_info_string(task)
    let max_key_len = max(map(copy(keys(task)), 'strdisplaywidth(v:val)'))

    for key in kronos#interface#gui#config().info.key
      let value   = string(task[key])
      let spaces  = repeat(' ', max_key_len - strdisplaywidth(key))
      let message = key . spaces . ': ' . value

      call kronos#utils#log#info(message)
    endfor
  catch 'task-not-found'
    return kronos#utils#log#error('Task not found.')
  catch
    return kronos#utils#log#error('Error while showing task info.')
  endtry
endfunction

" --------------------------------------------------------------------- # List #

function! kronos#interface#cli#list(args)
  try
    let tasks = kronos#interface#common#list(g:kronos_database)
    let max_key_len = max(map(copy(tasks), 'strdisplaywidth(v:val.id)'))

    for task in tasks
      let spaces  = repeat(' ', max_key_len - strdisplaywidth(task.id))
      let message = printf('[%d]%s: %s', task.id, spaces, task.desc)

      call kronos#utils#log#info(message)
    endfor
  catch
    return kronos#utils#log#error('Error while showing tasks list.')
  endtry
endfunction

" ------------------------------------------------------------------- # Update #

function! kronos#interface#cli#update(args)
  try
    call kronos#interface#common#update(g:kronos_database, localtime(), a:args)
  catch 'task-not-found'
    return kronos#utils#log#error('Task not found.')
  catch
    return kronos#utils#log#error('Error while updating task.')
  endtry
endfunction

" ------------------------------------------------------------------- # Delete #

function! kronos#interface#cli#delete(id)
  try
    call kronos#interface#common#delete(g:kronos_database, a:id)
  catch 'task-not-found'
    return kronos#utils#log#error('Task not found.')
  catch 'operation-canceled'
    return kronos#utils#log#error('Operation canceled.')
  catch
    return kronos#utils#log#error('Error while deleting task.')
  endtry
endfunction

" -------------------------------------------------------------------- # Start #

function! kronos#interface#cli#start(id)
  try
    call kronos#interface#common#start(g:kronos_database, localtime(), a:id)
  catch 'task-not-found'
    return kronos#utils#log#error('Task not found.')
  catch 'task-already-active'
    return kronos#utils#log#error('Task already active.')
  catch
    return kronos#utils#log#error('Error while starting task.')
  endtry
endfunction

" --------------------------------------------------------------------- # Stop #

function! kronos#interface#cli#stop(id)
  try
    call kronos#interface#common#stop(g:kronos_database, localtime(), a:id)
  catch 'task-not-found'
    return kronos#utils#log#error('Task not found.')
  catch 'task-already-stopped'
    return kronos#utils#log#error('Task already stopped.')
  catch
    return kronos#utils#log#error('Error while stopping task.')
  endtry
endfunction

" ------------------------------------------------------------------- # Toggle #

function! kronos#interface#cli#toggle(id)
  try
    let task = kronos#task#read(g:kronos_database, a:id)
  catch 'task-not-found'
    return kronos#utils#log#error('Task not found.')
  catch
    return kronos#utils#log#error('Error while reading task.')
  endtry

  return task.active
    \? kronos#interface#cli#stop(a:id)
    \: kronos#interface#cli#start(a:id)
endfunction

" --------------------------------------------------------------------- # Done #

function! kronos#interface#cli#done(id)
  try
    call kronos#interface#common#done(g:kronos_database, localtime(), a:id)
  catch 'task-not-found'
    return kronos#utils#log#error('Task not found.')
  catch 'task-already-done'
    return kronos#utils#log#error('Task already done.')
  catch
    return kronos#utils#log#error('Error while marking task as done.')
  endtry
endfunction

" ------------------------------------------------------------------- # Undone #

function! kronos#interface#cli#undone(id)
  try
    call kronos#interface#common#undone(g:kronos_database, a:id)
  catch 'task-not-found'
    return kronos#utils#log#error('Task not found.')
  catch 'task-not-done'
    return kronos#utils#log#error('Task not done.')
  catch
    return kronos#utils#log#error('Error while marking task as undone.')
  endtry
endfunction

" ----------------------------------------------------------------- # Worktime #

function! kronos#interface#cli#worktime(args)
  let worktime = kronos#interface#common#worktime(
    \g:kronos_database,
    \localtime(),
    \a:args,
  \)

  let message  = kronos#utils#datetime#print_interval(worktime)
  call kronos#utils#log#info(message)
endfunction

" ------------------------------------------------------------------ # Context #

function! kronos#interface#cli#context(args)
  try
    call kronos#interface#common#context(a:args)
  catch
    return kronos#utils#log#error('Error while setting context.')
  endtry
endfunction
