function! kronos#database#Purge(database)
  if exists('s:cache') | unlet s:cache | endif
  if filereadable(a:database) | call delete(a:database) | endif
endfunction

function! kronos#database#ReadTasks(database)
  if exists('s:cache') | return s:cache | endif

  let s:cache = filereadable(a:database)
    \ ? map(readfile(a:database), 'eval(v:val)')
    \ : []

  return copy(s:cache)
endfunction

function! kronos#database#WriteTasks(database, tasks)
  let s:cache = copy(a:tasks)
  let l:data = copy(a:tasks)

  call map(l:data, 'string(v:val)')
  call writefile(l:data, a:database, 's')
endfunction

