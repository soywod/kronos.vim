"------------------------------------------------------------------------# Add #

function! kronos#ui#common#Add(database, dateref, args)
  let l:args = split(a:args, ' ')
  let [l:desc, l:tags, l:due] = s:ParseArgs(a:dateref, [], l:args)

  return kronos#api#task#Create(a:database, {
    \ 'desc': l:desc,
    \ 'tags': l:tags,
    \ 'due': l:due,
    \ 'active': 0,
    \ 'lastactive': 0,
    \ 'worktime': 0,
    \ 'done': 0,
  \})
endfunction

"---------------------------------------------------------------------# Update #

function! kronos#ui#common#Update(database, dateref, args)
  let [l:id; l:args] = split(a:args, ' ')
  let l:task = kronos#api#task#Read(a:database, l:id)
  let [l:desc, l:tags, l:due] = s:ParseArgs(a:dateref, l:task.tags, l:args)

  if ! empty(l:desc) && l:task.desc != l:desc
    let l:task.desc = l:desc
  endif

  if l:task.tags != l:tags
    let l:task.tags = l:tags
  endif

  if l:task.due != l:due
    let l:task.due = l:due
  endif

  call kronos#api#task#Update(a:database, l:id, l:task)

  return l:id
endfunction

"---------------------------------------------------------------------# Delete #

function! kronos#ui#common#Delete(database, id)
  let l:choice =
    \input('Do you really want to delete the task [' . a:id . '] (y/N) ? ')

  if l:choice !~? '^y'
    throw 'operation-canceled'
  endif

  call kronos#api#task#Delete(a:database, a:id)
endfunction

"----------------------------------------------------------------------# Start #

function! kronos#ui#common#Start(database, dateref, id)
  let l:task = kronos#api#task#Read(a:database, a:id)

  if  l:task.active | throw 'task-already-active' | endif
  let l:task.active = a:dateref

  call kronos#api#task#Update(a:database, a:id, l:task)
endfunction

"-----------------------------------------------------------------------# Stop #

function! kronos#ui#common#Stop(database, dateref, id)
  let l:task = kronos#api#task#Read(a:database, a:id)

  if  ! l:task.active | throw 'task-already-stopped' | endif
  let l:task.worktime += (a:dateref - l:task.active)
  let l:task.active = 0
  let l:task.lastactive = a:dateref

  call kronos#api#task#Update(a:database, a:id, l:task)
endfunction

"-----------------------------------------------------------------------# Done #

function! kronos#ui#common#Done(database, dateref, id)
  let l:task = kronos#api#task#Read(a:database, a:id)

  if  l:task.done | throw 'task-already-done' | endif
  if  l:task.active
    let l:task.worktime += (a:dateref - l:task.active)
    let l:task.active = 0
    let l:task.lastactive = a:dateref
  endif

  let l:task.done = a:dateref
  let l:task.id   = a:id . a:dateref

  call kronos#api#task#Update(a:database, a:id, l:task)
endfunction

"--------------------------------------------------------------------# Helpers #

function! s:ParseArgs(dateref, tags, args)
  let l:desc = []
  let l:due = 0
  let l:tags = copy(a:tags)
  let l:newtags = []
  let l:oldtags = []

  for l:arg in a:args
    if l:arg =~ '^+\w'
      call add(l:newtags, l:arg[1:])
    elseif l:arg =~ '^-\w'
      call add(l:oldtags, l:arg[1:])
    elseif l:arg =~ '^:\w*'
      let l:due = kronos#tool#datetime#ParseDue(a:dateref, l:arg)
    else
      call add(l:desc, l:arg)
    endif
  endfor

  for l:tag in l:newtags
    if index(l:tags, l:tag) == -1 | call add(l:tags, l:tag) | endif
  endfor

  for l:tag in l:oldtags
    let l:index = index(l:tags, l:tag)
    if l:index != -1 | call remove(l:tags, l:index) | endif
  endfor

  return [join(l:desc, ' '), l:tags, l:due]
endfunction

