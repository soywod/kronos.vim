function! kronos#cli#Add(database, dateref, args)
  let l:args = split(a:args, ' ')
  let [l:desc, l:tags, l:due] = s:ParseArgs(a:dateref, l:args)

  let l:id = kronos#task#Create(a:database, {
    \ 'desc': l:desc,
    \ 'tags': l:tags,
    \ 'due': l:due,
  \})

  echo 'Task [' . l:id . '] added.'
endfunction

function! kronos#cli#Info(database, id)
  try
    let l:task = kronos#task#Read(a:database, a:id)

    for [l:key, l:value] in items(l:task)
      echo l:key . ': ' . string(l:value)
    endfor
  catch 'task-not-found'
    call s:LogError('Task [' . a:id . '] not found.')
  endtry
endfunction

function! kronos#cli#List(database)
  let l:tasks = kronos#task#ReadAll(a:database)

  for l:task in l:tasks
    echo '[' . l:task.id . '] ' . l:task.desc
  endfor
endfunction

function! kronos#cli#Update(database, dateref, args)
  try
    let [l:id; l:args] = split(a:args, ' ')
  catch
    return s:LogError('Not enough arguments. Usage: KronosUpdate <id> <args>.')
  endtry

  try
    let l:task = kronos#task#Read(a:database, l:id)
  catch 'task-not-found'
    call s:LogError('Task [' . l:id . '] not found.')
  endtry

  let [l:desc, l:tags, l:due] = s:ParseArgs(a:dateref, l:args)

  if l:task.desc != l:desc | let l:task.desc = l:desc | endif
  if l:task.tags != l:tags | let l:task.tags = l:tags | endif
  if l:task.due != l:due | let l:task.due = l:due | endif

  let l:updated = kronos#task#Update(a:database, l:id, l:task)

  echo 'Task [' . l:id . '] updated.'
endfunction

function! kronos#cli#Delete(database, id)
  try
    call kronos#task#Delete(a:database, a:id)
    echo 'Task [' . a:id . '] deleted.'
  catch 'task-not-found'
    call s:LogError('Task [' . a:id . '] not found.')
  endtry
endfunction

function! s:ParseArgs(dateref, args)
  let l:desc = []
  let l:tags = []
  let l:due = 0

  for l:arg in a:args
    if l:arg =~ '^+\w'
      call add(l:tags, l:arg[1:])
    elseif l:arg =~ '^:\w*'
      let l:due = kronos#datetime#ParseDue(a:dateref, l:arg)
    else
      call add(l:desc, l:arg)
    endif
  endfor

  return [join(l:desc, ' '), l:tags, l:due]
endfunction

function! s:LogError(msg)
  echohl ErrorMsg
  echo a:msg
  echohl None
endfunction

