"----------------------------------------------------------------------# Purge #

function! kronos#api#database#Purge(database)
  if exists('s:cache') | unlet s:cache | endif
  if filereadable(a:database) | call delete(a:database) | endif
endfunction

"-----------------------------------------------------------------# Read tasks #

function! kronos#api#database#ReadTasks(database)
  if exists('s:cache') | return s:cache | endif

  let s:cache = filereadable(a:database)
    \ ? map(readfile(a:database), 'eval(v:val)')
    \ : []

  return copy(s:cache)
endfunction

"----------------------------------------------------------------# Write tasks #

function! kronos#api#database#WriteTasks(database, tasks)
  let s:cache = copy(a:tasks)
  let l:data = copy(a:tasks)

  call map(l:data, 'string(v:val)')
  call writefile(l:data, a:database, 's')
endfunction

