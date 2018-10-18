" ------------------------------------------------------------------- # Create #

function! kronos#task#create(database, task)
  let tasks = kronos#database#read(a:database).tasks
  let task = copy(a:task)

  if has_key(task, 'id')
    if len(filter(copy(tasks), 'v:val.id == task.id'))
      throw 'task-already-exist'
    endif
  else
    let task.id = kronos#task#generate_id(tasks)
  endif

  let tasks_new = add(copy(tasks), task)
  call kronos#database#write(a:database, {'tasks': tasks_new})

  return task.id
endfunction

" --------------------------------------------------------------------- # Read #

function! kronos#task#read(database, id)
  let tasks = kronos#database#read(a:database).tasks
  let index = kronos#task#get_index_by_id(tasks, a:id)

  return tasks[index]
endfunction

" ----------------------------------------------------------------- # Read all #

function! kronos#task#read_all(database)
  return kronos#database#read(a:database).tasks
endfunction

" ------------------------------------------------------------------- # Update #

function! kronos#task#update(database, id, task)
  let tasks_new = copy(kronos#database#read(a:database).tasks)
  let index = kronos#task#get_index_by_id(tasks_new, a:id)

  let tasks_new[index] = copy(a:task)
  call kronos#database#write(a:database, {'tasks': tasks_new})
endfunction

" ------------------------------------------------------------------- # Delete #

function! kronos#task#delete(database, id)
  let tasks_new = copy(kronos#database#read(a:database).tasks)
  let index = kronos#task#get_index_by_id(tasks_new, a:id)

  call remove(tasks_new, index)
  call kronos#database#write(a:database, {'tasks': tasks_new})
endfunction

" -------------------------------------------------------------------- # Utils #

function! kronos#task#generate_id(tasks)
  let ids = map(copy(a:tasks), 'v:val.id')
  let id_new = 1

  while index(ids, id_new) != -1
    let id_new += 1
  endwhile

  return id_new
endfunction

function! kronos#task#get_index_by_id(tasks, id)
  let index = 0

  for task in a:tasks
    if  task.id == a:id | return index | endif
    let index += 1
  endfor

  throw 'task-not-found'
endfunction

function! kronos#task#to_info_string(task)
  let task = copy(a:task)

  let Print_date     = function('kronos#utils#datetime#print_date')
  let Print_interval = function('kronos#utils#datetime#print_interval')

  let worktime_str = task.active
    \? Print_interval(task.worktime + localtime() - task.active)
    \: task.worktime ? Print_interval(task.worktime) : ''

  let task.active      = task.active      ? Print_date(task.active)      : ''
  let task.done        = task.done        ? Print_date(task.done)        : ''
  let task.due         = task.due         ? Print_date(task.due)         : ''
  let task.last_active = task.last_active ? Print_date(task.last_active) : ''

  let task.worktime   = worktime_str
  let task.tags       = join(task.tags, ' ')

  return task
endfunction

function! kronos#task#to_list_string(task)
  let task = copy(a:task)

  let Print_diff = function('kronos#utils#datetime#print_diff', [localtime()])
  let Print_interval  = function('kronos#utils#datetime#print_interval')

  let task.id = task.done ? '-' : task.id
  let task.tags = join(task.tags, ' ')
  let task.worktime = task.worktime ? Print_interval(task.worktime) : ''

  let task.active      = task.active      ? Print_diff(task.active)      : ''
  let task.done        = task.done        ? Print_diff(task.done)        : ''
  let task.due         = task.due         ? Print_diff(task.due)         : ''
  let task.last_active = task.last_active ? Print_diff(task.last_active) : ''

  return task
endfunction
