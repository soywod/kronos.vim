" --------------------------------------------------------------------- # CRUD #

function! kronos#task#create(task)
  let task = copy(a:task)
  let tasks = kronos#database#read().tasks

  for tag in copy(g:kronos_context)
    if index(task.tags, tag) == -1
      call add(task.tags, tag)
    endif
  endfor

  if has_key(task, 'id')
    call s:throw_if_exists(task, tasks)
  else
    let task.id = kronos#task#generate_id(tasks)
  endif

  call add(tasks, task)
  call kronos#database#write({'tasks': tasks})

  return task.id
endfunction

function! kronos#task#read(id)
  let tasks = kronos#database#read().tasks
  let index = kronos#task#get_index_by_id(tasks, a:id)

  return tasks[index]
endfunction

function! kronos#task#read_all()
  return kronos#database#read().tasks
endfunction

function! kronos#task#update(id, task)
  let tasks = kronos#database#read().tasks
  let index = kronos#task#get_index_by_id(tasks, a:id)
  let tasks[index] = copy(kronos#utils#assign(tasks[index], a:task))

  return kronos#database#write({'tasks': tasks})
endfunction

function! kronos#task#delete(id)
  let tasks = kronos#database#read().tasks
  let index = kronos#task#get_index_by_id(tasks, a:id)
  call remove(tasks, index)

  return kronos#database#write({'tasks': tasks})
endfunction

" --------------------------------------------------------------------- # List #

function! kronos#task#list()
  let tasks = kronos#database#read().tasks

  if (!empty(g:kronos_context))
    let tasks = filter(copy(tasks), 's:match_one_tag(v:val, g:kronos_context)')
  endif

  if (g:kronos_hide_done)
    let tasks = filter(copy(tasks), 'v:val.done == 0')
  endif

  return tasks
endfunction

function! s:match_one_tag(task, tags)
  for tag in a:task.tags
    if index(a:tags, tag) > -1 | return 1 | endif
  endfor

  return 0
endfunction

" ------------------------------------------------------------------- # Toggle #

function! kronos#task#toggle(id)
  let date_ref = localtime()
  let task = kronos#task#read(a:id)

  if task.active
    return kronos#task#update(a:id, {
      \'active': 0,
      \'last_active': date_ref,
      \'worktime': date_ref - task.active + task.worktime,
    \})
  endif

  return kronos#task#update(a:id, {
    \'active': date_ref,
  \})
endfunction

" --------------------------------------------------------------------- # Done #

function! kronos#task#done(id)
  let date_ref = localtime()
  let task = kronos#task#read(a:id)

  let update = {
    \'done': date_ref,
    \'id': a:id . date_ref,
  \}

  if task.active
    let update = kronos#utils#assign(update, {
      \'active': 0,
      \'last_active': date_ref,
      \'worktime': date_ref - task.active + task.worktime,
    \})
  endif

  return kronos#task#update(a:id, update)
endfunction

" -------------------------------------------------------------------- # Utils #

function! s:throw_if_exists(task, tasks)
  for task in a:tasks
    if task.id == a:task.id
      throw 'task already exist'
    endif
  endfor
endfunction

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

  throw 'task not found'
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
