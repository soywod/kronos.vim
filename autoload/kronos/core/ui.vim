" ---------------------------------------------------------------------- # Add #

function! kronos#core#ui#Add(database, dateref, args)
  let args = split(a:args, ' ')
  let [desc, tags, due] = s:ParseArgs(a:dateref, args, {})

  for tag in copy(g:kronos_context)
    if index(tags, tag) == -1
      call add(tags, tag)
    endif
  endfor

  let id = kronos#core#task#Create(a:database, {
    \'desc'      : desc,
    \'tags'      : tags,
    \'due'       : due,
    \'active'    : 0,
    \'lastactive': 0,
    \'worktime'  : 0,
    \'done'      : 0,
  \})

  redraw
  let message = printf('Task [%d] added.', id)
  call kronos#tool#log#Info(message)
endfunction

" --------------------------------------------------------------------- # List #

function! kronos#core#ui#List(database)
  let tasks = kronos#core#task#ReadAll(a:database)

  if (! empty(g:kronos_context))
    let tasks = filter(copy(tasks), 's:MatchOneTag(v:val, g:kronos_context)')
  endif

  if (g:kronos_hide_done)
    let tasks = filter(copy(tasks), 'v:val.done == 0')
  endif

  return tasks
endfunction

" ------------------------------------------------------------------- # Update #

function! kronos#core#ui#Update(database, dateref, args)
  let [id; args] = split(a:args, ' ')
  let task = kronos#core#task#Read(a:database, id)
  let [desc, tags, due] = s:ParseArgs(a:dateref, args, task)

  if ! empty(desc) && task.desc != desc | let task.desc = desc | endif

  if task.tags != tags | let task.tags = tags | endif
  if task.due  != due  | let task.due  = due  | endif

  call kronos#core#task#Update(a:database, id, task)

  redraw
  let message = printf('Task [%d] updated.', id)
  call kronos#tool#log#Info(message)
endfunction

" ------------------------------------------------------------------- # Delete #

function! kronos#core#ui#Delete(database, id)
  let prompt = 'Do you really want to delete the task [' . a:id . '] (y/N) ? '
  let choice = input(prompt)
  if  choice !~? '^y' | throw 'operation-canceled' | endif

  call kronos#core#task#Delete(a:database, a:id)

  redraw
  let message = printf('Task [%d] deleted.', a:id)
  call kronos#tool#log#Info(message)
endfunction

" -------------------------------------------------------------------- # Start #

function! kronos#core#ui#Start(database, dateref, id)
  let task = kronos#core#task#Read(a:database, a:id)
  if  task.active | throw 'task-already-active' | endif

  let task.active = a:dateref

  call kronos#core#task#Update(a:database, a:id, task)

  redraw
  let message = printf('Task [%d] started.', a:id)
  call kronos#tool#log#Info(message)
endfunction

" --------------------------------------------------------------------- # Stop #

function! kronos#core#ui#Stop(database, dateref, id)
  let task = kronos#core#task#Read(a:database, a:id)
  if  ! task.active | throw 'task-already-stopped' | endif

  let task.worktime += (a:dateref - task.active)
  let task.active = 0
  let task.lastactive = a:dateref

  call kronos#core#task#Update(a:database, a:id, task)

  redraw
  let message = printf('Task [%d] stopped.', a:id)
  call kronos#tool#log#Info(message)
endfunction

" ------------------------------------------------------------------- # Toggle #

function! kronos#core#ui#Toggle(database, dateref, id)
  let task = kronos#core#task#Read(a:database, a:id)

  return task.active
    \? kronos#core#ui#Stop(a:database, a:dateref, a:id)
    \: kronos#core#ui#Start(a:database, a:dateref, a:id)
endfunction

" --------------------------------------------------------------------- # Done #

function! kronos#core#ui#Done(database, dateref, id)
  let task = copy(kronos#core#task#Read(a:database, a:id))
  if  task.done | throw 'task-already-done' | endif

  if  task.active
    let task.worktime += (a:dateref - task.active)
    let task.active = 0
    let task.lastactive = a:dateref
  endif

  let task.done = a:dateref
  let task.id   = a:id . a:dateref

  call kronos#core#task#Update(a:database, a:id, task)

  redraw
  let message = printf('Task [%d] done.', a:id)
  call kronos#tool#log#Info(message)
endfunction

" ------------------------------------------------------------------- # Undone #

function! kronos#core#ui#Undone(database, id)
  let tasks = kronos#core#database#Read(a:database)
  let task = copy(kronos#core#task#Read(a:database, a:id))
  if  ! task.done | throw 'task-not-done' | endif

  let task.done = 0
  let task.id   = kronos#tool#task#GenerateId(tasks)

  call kronos#core#task#Update(a:database, a:id, task)

  redraw
  let message = printf('Task [%d] undone.', task.id)
  call kronos#tool#log#Info(message)
endfunction

" ----------------------------------------------------------------- # Worktime #

function! kronos#core#ui#Worktime(database, dateref, args)
  let args = split(a:args, ' ')
  let [desc, tags, due] = s:ParseArgs(a:dateref, args, {})

  let tasks = kronos#core#task#ReadAll(a:database)
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

function! kronos#core#ui#Context(args)
  let g:kronos_context = split(a:args, ' ')

  redraw
  let message = printf('Context [%s] set.', g:kronos_context)
  call kronos#tool#log#Info(message)
endfunction

" ------------------------------------------------------------------- # Helper #

function! s:ParseArgs(dateref, args, task)
  let desc    = []
  let oldtags = []
  let newtags = []

  if len(a:task)
    let due  = a:task.due
    let tags = copy(a:task.tags)
  else
    let due  = 0
    let tags = []
  endif

  for arg in a:args
    if arg =~ '^+\w'
      call add(newtags, arg[1:])
    elseif arg =~ '^-\w'
      call add(oldtags, arg[1:])
    elseif arg =~ '^:\w*'
      let due = kronos#tool#datetime#ParseDue(a:dateref, arg)
    else
      call add(desc, arg)
    endif
  endfor

  for tag in newtags
    if index(tags, tag) == -1 | call add(tags, tag) | endif
  endfor

  for tag in oldtags
    let index = index(tags, tag)
    if  index != -1 | call remove(tags, index) | endif
  endfor

  return [join(desc, ' '), tags, due]
endfunction

function! s:MatchOneTag(task, tags)
  for tag in a:task.tags
    if index(a:tags, tag) + 1 | return 1 | endif
  endfor

  return 0
endfunction

