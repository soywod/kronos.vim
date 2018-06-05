"----------------------------------------------------------------------# Purge #

function! kronos#api#database#Purge(database)
  if exists('s:cache') | unlet s:cache | endif
  if filereadable(a:database) | call delete(a:database) | endif
endfunction

"-----------------------------------------------------------------# Read tasks #

function! kronos#api#database#ReadTasks(database)
  if exists('s:cache') | return s:cache | endif

  let s:cache = filereadable(a:database)
    \? map(readfile(a:database), 'eval(v:val)')
    \: []

  return s:cache
endfunction

"----------------------------------------------------------------# Write tasks #

function! kronos#api#database#WriteTasks(database, tasks)
  let l:tasksundone = filter(copy(a:tasks), '! v:val.done')
  let l:tasksdone   = filter(copy(a:tasks), 'v:val.done')
  let s:cache       = l:tasksundone + l:tasksdone
  let l:data        = copy(s:cache)

  call map(l:data, 'string(v:val)')
  call writefile(l:data, a:database, 's')
endfunction

