let s:localtime = function('kronos#utils#date#localtime')

" --------------------------------------------------------------------- # CRUD #

function! kronos#task#create(task)
  let database = kronos#database#read()
  let task = copy(a:task)
  let tasks = database.tasks

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

  let task.index = -(task.id . s:localtime())
  call add(tasks, task)

  call kronos#database#write({'tasks': tasks})

  return task
endfunction

function! kronos#task#read(id)
  let tasks = kronos#database#read().tasks
  let position = kronos#task#get_position(tasks, a:id)

  return tasks[position]
endfunction

function! kronos#task#read_all()
  return kronos#database#read().tasks
endfunction

function! kronos#task#update(id, task)
  let tasks = kronos#database#read().tasks
  let position = kronos#task#get_position(tasks, a:id)
  let prev_task = tasks[position]
  let tasks[position] = kronos#utils#assign(tasks[position], a:task)

  call kronos#database#write({'tasks': tasks})

  return prev_task
endfunction

function! kronos#task#delete(id)
  let tasks = kronos#database#read().tasks
  let position = kronos#task#get_position(tasks, a:id)
  let index = tasks[position].index
  call remove(tasks, position)

  call kronos#database#write({'tasks': tasks})

  return index
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

function! s:start(task)
  return kronos#task#update(a:task.id, {
    \'active': 1,
    \'start': a:task.start + [s:localtime()],
  \})
endfunction

function! s:stop(task)
  return kronos#task#update(a:task.id, {
    \'active': 0,
    \'stop': a:task.stop + [s:localtime()],
  \})
endfunction

function! kronos#task#toggle(id)
  let task = kronos#task#read(a:id)
  return task.active ? s:stop(task) : s:start(task)
endfunction

" --------------------------------------------------------------------- # Done #

function! kronos#task#done(id)
  let date_ref = s:localtime()
  let task = kronos#task#read(a:id)

  let update = {
    \'done': date_ref,
    \'id': task.index,
  \}

  if task.active
    let update = kronos#utils#assign(update, {
      \'active': 0,
      \'stop': task.stop + [s:localtime()],
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

function! kronos#task#get_position(tasks, id)
  let position = 0

  for task in a:tasks
    if  task.id == a:id | return position | endif
    let position += 1
  endfor

  throw 'task not found'
endfunction

function! kronos#task#to_info_string(task)
  let task = copy(a:task)

  let task.tags   = join(task.tags, ' ')
  let task.active = task.active ? 'true' : 'false'
  let task.done = task.done ? kronos#utils#date(task.done) : ''
  let task.due  = task.due  ? kronos#utils#date(task.due)  : ''
  return task
endfunction

function! kronos#task#to_list_string(task)
  let task = copy(a:task)

  let Print_diff = function('kronos#utils#date_diff', [s:localtime()])
  let Print_interval  = function('kronos#utils#date_interval')

  let task.tags = join(task.tags, ' ')

  let task.active = task.active ? Print_diff(task.start[-1]) : ''
  let task.done   = task.done   ? Print_diff(task.done)      : ''
  let task.due    = task.due    ? Print_diff(task.due)       : ''

  return task
endfunction
