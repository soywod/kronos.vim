" ---------------------------------------------------------------------- # Add #

function! kronos#interface#common#add(date_ref, args)
  let args = split(a:args, ' ')
  let [desc, tags, due] = kronos#interface#common#parse_args(a:date_ref, args, {})

  for tag in copy(g:kronos_context)
    if index(tags, tag) == -1
      call add(tags, tag)
    endif
  endfor

  let task = {
    \'desc': desc,
    \'tags': tags,
    \'due': due,
    \'active': 0,
    \'last_active': 0,
    \'worktime': 0,
    \'done': 0,
  \}

  let task.id = kronos#task#create(task)

  if g:kronos_sync
    call kronos#sync#common#bump_version()
    call kronos#sync#common#send({'type': 'create', 'task': task})
  endif

"   let message = printf('Task [%d] added.', task.id)
"   call kronos#utils#log#info(message)
endfunction

" --------------------------------------------------------------------- # List #

function! kronos#interface#common#list()
  let tasks = kronos#task#read_all()

  if (!empty(g:kronos_context))
    let tasks = filter(copy(tasks), 's:match_one_tag(v:val, g:kronos_context)')
  endif

  if (g:kronos_hide_done)
    let tasks = filter(copy(tasks), 'v:val.done == 0')
  endif

  return tasks
endfunction

" ------------------------------------------------------------------- # Update #

function! kronos#interface#common#update(date_ref, args)
  let [id; args] = split(a:args, ' ')
  let task = kronos#task#read(id)
  let [desc, tags, due] = kronos#interface#common#parse_args(a:date_ref, args, task)

  if ! empty(desc) && task.desc != desc | let task.desc = desc | endif

  if task.tags != tags | let task.tags = tags | endif
  if task.due  != due  | let task.due  = due  | endif

  call kronos#task#update(id, task)

  if g:kronos_sync
    call kronos#sync#common#bump_version()
    call kronos#sync#common#send({'type': 'update', 'task': task})
  endif

  " let message = printf('Task [%d] updated.', id)
  " call kronos#utils#log#info(message)
endfunction

" ------------------------------------------------------------------- # Delete #

function! kronos#interface#common#delete(id)
  call kronos#task#delete(a:id)

  if g:kronos_sync
    call kronos#sync#common#bump_version()
    call kronos#sync#common#send({'type': 'delete', 'task_id': a:id})
  endif

  " let message = printf('Task [%d] deleted.', a:id)
  " call kronos#utils#log#info(message)
endfunction

" -------------------------------------------------------------------- # Start #

function! kronos#interface#common#start(date_ref, id)
  let task = kronos#task#read(a:id)
  if  task.active | throw 'task already active' | endif

  let task.active = a:date_ref

  call kronos#task#update(a:id, task)

  " let message = printf('Task [%d] started.', a:id)
  " call kronos#utils#log#info(message)
endfunction

" --------------------------------------------------------------------- # Stop #

function! kronos#interface#common#stop(date_ref, id)
  let task = kronos#task#read(a:id)
  if  ! task.active | throw 'task already stopped' | endif

  let task.worktime += (a:date_ref - task.active)
  let task.active = 0
  let task.last_active = a:date_ref

  call kronos#task#update(a:id, task)

  " let message = printf('Task [%d] stopped.', a:id)
  " call kronos#utils#log#info(message)
endfunction

" ------------------------------------------------------------------- # Toggle #

function! kronos#interface#common#toggle(date_ref, id)
  let task = kronos#task#read(a:id)

  return task.active
    \? kronos#interface#common#stop(a:date_ref, a:id)
    \: kronos#interface#common#start(a:date_ref, a:id)
endfunction

" --------------------------------------------------------------------- # Done #

function! kronos#interface#common#done(date_ref, id)
  let task = copy(kronos#task#read(a:id))
  if  task.done | throw 'task already done' | endif

  if  task.active
    let task.worktime += (a:date_ref - task.active)
    let task.active = 0
    let task.last_active = a:date_ref
  endif

  let task.done = a:date_ref
  let task.id   = a:id . a:date_ref

  call kronos#task#update(a:id, task)

  " let message = printf('Task [%d] done.', a:id)
  " call kronos#utils#log#info(message)
endfunction

" ------------------------------------------------------------------- # Undone #

function! kronos#interface#common#undone(id)
  let tasks = kronos#database#read().tasks
  let task = copy(kronos#task#read(a:id))
  if  ! task.done | throw 'task not done' | endif

  let task.done = 0
  let task.id = kronos#task#generate_id(tasks)

  call kronos#task#update(a:id, task)

  " let message = printf('Task [%d] undone.', task.id)
  " call kronos#utils#log#info(message)
endfunction

" ----------------------------------------------------------------- # Worktime #

function! kronos#interface#common#worktime(date_ref, args)
  let tags  = split(a:args, ' ')
  let tasks = kronos#task#read_all()
  let worktime = 0

  for task in tasks
    let matchtags = filter(copy(tags), 'index(task.tags, v:val) + 1')

    if matchtags == tags
      let worktime += task.worktime
    endif
  endfor

  return worktime
endfunction

" ------------------------------------------------------------------ # Context #

function! kronos#interface#common#context(args)
  let g:kronos_context = split(a:args, ' ')

  " let message = printf('Context %s set.', g:kronos_context)
  " call kronos#utils#log#info(message)
endfunction

" -------------------------------------------------------------------- # Utils #

function! kronos#interface#common#parse_args(date_ref, args, task)
  let args = split(a:args, ' ')

  let desc     = []
  let tags_old = []
  let tags_new = []

  if len(a:task)
    let due  = a:task.due
    let tags = copy(a:task.tags)
  else
    let due  = 0
    let tags = []
  endif

  for arg in args
    if arg =~ '^+\w'
      call add(tags_new, arg[1:])
    elseif arg =~ '^-\w'
      call add(tags_old, arg[1:])
    elseif arg =~ '^:\w*'
      let due = kronos#utils#datetime#parse_due(a:date_ref, arg)
    else
      call add(desc, arg)
    endif
  endfor

  for tag in tags_new
    if index(tags, tag) == -1 | call add(tags, tag) | endif
  endfor

  for tag in tags_old
    let index = index(tags, tag)
    if  index != -1 | call remove(tags, index) | endif
  endfor

  return [join(desc, ' '), tags, due]
endfunction
