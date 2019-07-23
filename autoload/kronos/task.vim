let s:assign = function('kronos#utils#assign')
let s:sum = function('kronos#utils#sum')
let s:strftime = function('strftime', ['%c'])
let s:duration = function('kronos#utils#date#duration')
let s:relative = function('kronos#utils#date#relative')
let s:match_one = function('kronos#utils#match_one')

" --------------------------------------------------------------------- # CRUD #

function! kronos#task#create(ids, task)
  let task = copy(a:task)

  for tag in copy(g:kronos_context)
    if index(task.tags, tag) == -1
      call add(task.tags, tag)
    endif
  endfor

  let task.id = has_key(task, 'id') ? task.id : kronos#task#generate_id(a:ids)
  let task.index = -(localtime() . task.id)

  if g:kronos_backend == 'taskwarrior'
    let task.id = kronos#backends#taskwarrior#create(task)
  endif

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

function! kronos#task#update(prev_task, next_task)
  if g:kronos_backend == 'taskwarrior'
    call kronos#backends#taskwarrior#update(a:prev_task, a:next_task)
  endif

  return s:assign(a:prev_task, a:next_task)
endfunction

" --------------------------------------------------------------------- # List #

function! kronos#task#list()
  let tasks = kronos#database#read().tasks

  if (!empty(g:kronos_context))
    let tasks = filter(copy(tasks), 's:match_one(v:val.tags, g:kronos_context)')
  endif

  if (g:kronos_hide_done)
    let tasks = filter(copy(tasks), 'v:val.done == 0')
  endif

  return tasks
endfunction

" ------------------------------------------------------------------- # Toggle #

function! kronos#task#toggle(task)
  let update = a:task.active ? {
    \'active': 0,
    \'stop': a:task.stop + [localtime()],
  \} : {
    \'active': 1,
    \'start': a:task.start + [localtime()],
  \}

  if g:kronos_backend == 'taskwarrior'
    call kronos#backends#taskwarrior#toggle(a:task)
  endif

  return s:assign(a:task, update)
endfunction

" --------------------------------------------------------------------- # Done #

function! kronos#task#done(task)
  let date_ref = localtime()

  if g:kronos_backend == 'taskwarrior'
    call kronos#backends#taskwarrior#done(a:task.id)
  endif

  let task = s:assign(a:task, {
    \'done': date_ref,
    \'id': a:task.index,
  \})

  if a:task.active
    let task = s:assign(task, {
      \'active': 0,
      \'stop': task.stop + [localtime()],
    \})
  endif

  return task
endfunction

" -------------------------------------------------------------------- # Utils #

function! s:throw_if_exists(task, ids)
  for id in a:ids
    if a:task.id == id
      throw 'task already exist'
    endif
  endfor
endfunction

function! kronos#task#generate_id(ids)
  let id_new = 1

  while index(a:ids, id_new) != -1
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

  let starts = task.start
  let stops  = task.active ? task.stop + [localtime()] : task.stop

  let task.tags   = join(task.tags, ' ')
  let task.active = task.active ? 'true' : 'false'
  let task.done = task.done ? s:strftime(task.done) : ''
  let task.due  = task.due  ? s:strftime(task.due)  : ''
  let task.worktime = s:duration(s:sum(stops) - s:sum(starts))

  return task
endfunction

function! kronos#task#to_list_string(task)
  let task = copy(a:task)
  let now = localtime()

  let task.tags   = join(task.tags, ' ')
  let task.active = task.active ? s:relative(now, task.start[-1]) : ''
  let task.done   = task.done   ? s:relative(now, task.done)      : ''
  let task.due    = task.due    ? s:relative(now, task.due)       : ''

  return task
endfunction
