"------------------------------------------------------------------------# Add #

function! kronos#ui#cli#Add(database, dateref, args)
  let l:args = split(a:args, ' ')
  let [l:desc, l:tags, l:due] = s:ParseArgs(a:dateref, [], l:args)

  let l:id = kronos#api#task#Create(a:database, {
    \ 'desc': l:desc,
    \ 'tags': l:tags,
    \ 'due': l:due,
    \ 'active': 0,
    \ 'lastactive': 0,
    \ 'worktime': 0,
    \ 'done': 0,
  \})

  echo 'Task [' . l:id . '] added.'
endfunction

"-----------------------------------------------------------------------# Info #

function! kronos#ui#cli#Info(database, id)
  try
    let l:task = kronos#api#task#Read(a:database, a:id)

    for [l:key, l:value] in items(l:task)
      echo l:key . ': ' . string(l:value)
    endfor
  catch 'task-not-found'
    return kronos#tool#logging#Error('Task [' . a:id . '] not found.')
  endtry
endfunction

"-----------------------------------------------------------------------# List #

function! kronos#ui#cli#List(database)
  let l:tasks = kronos#api#task#ReadAll(a:database)

  for l:task in l:tasks
    echo '[' . l:task.id . '] ' . l:task.desc
  endfor
endfunction

"---------------------------------------------------------------------# Update #

function! kronos#ui#cli#Update(database, dateref, args)
  try
    let [l:id; l:args] = split(a:args, ' ')
  catch
    let l:msg = 'Not enough arguments. Usage: KronosUpdate <id> <args>.'
    return kronos#tool#logging#Error(l:msg)
  endtry

  try
    let l:task = kronos#api#task#Read(a:database, l:id)
  catch 'task-not-found'
    return kronos#tool#logging#Error('Task [' . l:id . '] not found.')
  endtry

  let [l:desc, l:tags, l:due] = s:ParseArgs(a:dateref, l:task.tags, l:args)

  if l:task.desc != l:desc | let l:task.desc = l:desc | endif
  if l:task.tags != l:tags | let l:task.tags = l:tags | endif
  if l:task.due != l:due | let l:task.due = l:due | endif

  call kronos#api#task#Update(a:database, l:id, l:task)

  echo 'Task [' . l:id . '] updated.'
endfunction

"---------------------------------------------------------------------# Delete #

function! kronos#ui#cli#Delete(database, id)
  try
    call kronos#api#task#Delete(a:database, a:id)
    echo 'Task [' . a:id . '] deleted.'
  catch 'task-not-found'
    return kronos#tool#logging#Error('Task [' . a:id . '] not found.')
  endtry
endfunction

"----------------------------------------------------------------------# Start #

function! kronos#ui#cli#Start(database, dateref, id)
  try
    let l:task = kronos#api#task#Read(a:database, a:id)
  catch 'task-not-found'
    return kronos#tool#logging#Error('Task [' . a:id . '] not found.')
  endtry

  if l:task.active
    return kronos#tool#logging#Error('Task [' . a:id . '] already active.')
  endif

  let l:task.active = a:dateref

  call kronos#api#task#Update(a:database, a:id, l:task)
endfunction

"-----------------------------------------------------------------------# Stop #

function! kronos#ui#cli#Stop(database, dateref, id)
  try
    let l:task = kronos#api#task#Read(a:database, a:id)
  catch 'task-not-found'
    return kronos#tool#logging#Error('Task [' . a:id . '] not found.')
  endtry

  if ! l:task.active
    return kronos#tool#logging#Error('Task [' . a:id . '] already stopped.')
  endif

  let l:task.worktime += (a:dateref - l:task.active)
  let l:task.active = 0
  let l:task.lastactive = a:dateref

  call kronos#api#task#Update(a:database, a:id, l:task)
endfunction

"-----------------------------------------------------------------------# Done #

function! kronos#ui#cli#Done(database, dateref, id)
  try
    let l:task = kronos#api#task#Read(a:database, a:id)
  catch 'task-not-found'
    return kronos#tool#logging#Error('Task [' . a:id . '] not found.')
  endtry

  if l:task.done
    return kronos#tool#logging#Error('Task [' . a:id . '] already done.')
  endif

  if l:task.active
    let l:task.worktime += (a:dateref - l:task.active)
    let l:task.active = 0
    let l:task.lastactive = a:dateref
  endif

  let l:task.done = a:dateref

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

