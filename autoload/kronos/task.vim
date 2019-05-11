let s:assign = function('kronos#utils#assign')
let s:localtime = function('kronos#utils#date#localtime')
let s:strftime = function('strftime', ['%c'])
let s:date_diff = function('kronos#utils#date#diff')

" --------------------------------------------------------------------- # CRUD #

function! kronos#task#create(tasks, task)
  let task = copy(a:task)

  for tag in copy(g:kronos_context)
    if index(task.tags, tag) == -1
      call add(task.tags, tag)
    endif
  endfor

  if has_key(task, 'id')
    call s:throw_if_exists(task, a:tasks)
  else
    let task.id = kronos#task#generate_id(a:tasks)
  endif

  let task.index = -(s:localtime() . task.id)

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

function! kronos#task#update(task, update)
  let tasks = kronos#database#read().tasks
  let position = kronos#task#get_position(tasks, a:task.id)
  let tasks[position] = s:assign(a:task, a:update)

  call kronos#database#write({'tasks': tasks})
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

function! kronos#task#toggle(task)
  let update = a:task.active ? {
    \'active': 0,
    \'stop': a:task.stop + [s:localtime()],
  \} : {
    \'active': 1,
    \'start': a:task.start + [s:localtime()],
  \}

  return s:assign(a:task, update)
endfunction

" --------------------------------------------------------------------- # Done #

function! kronos#task#done(task)
  let date_ref = s:localtime()

  let task = s:assign(a:task, {
    \'done': date_ref,
    \'id': a:task.index,
  \})

  if a:task.active
    let task = s:assign(task, {
      \'active': 0,
      \'stop': task.stop + [s:localtime()],
    \})
  endif

  return task
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
  let ids = map(copy(a:tasks), "has_key(v:val, 'id') ? v:val.id : -1")
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
  let task.done = task.done ? s:strftime(task.done) : ''
  let task.due  = task.due  ? s:strftime(task.due)  : ''
  return task
endfunction

function! kronos#task#to_list_string(task)
  let task = copy(a:task)
  let PrintDiff = function(s:date_diff, [s:localtime()])

  let task.tags   = join(task.tags, ' ')
  let task.active = task.active ? PrintDiff(task.start[-1])  : ''
  let task.done   = task.done   ? PrintDiff(task.done)       : ''
  let task.due    = task.due    ? PrintDiff(task.due)        : ''

  return task
endfunction
