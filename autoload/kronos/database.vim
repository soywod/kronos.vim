function! kronos#database#ReadTasks(database)
  if ! filereadable(a:database) | return [] | endif
  return map(readfile(a:database), 'eval(v:val)')
endfunction

function! kronos#database#WriteTasks(database, tasks)
  let l:tasks = map(copy(a:tasks), 'string(v:val)')
  call writefile(l:tasks, a:database, 's')
endfunction

