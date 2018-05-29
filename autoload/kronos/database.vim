function! kronos#database#ReadTasks(database)
  if ! filereadable(a:database)
    call kronos#database#WriteTasks(a:database, [])
    return []
  endif

  try
    call execute('source ' . a:database)
    return g:kronos_tasks
  finally
    unlet g:kronos_tasks
  endtry
endfunction

function! kronos#database#WriteTasks(database, tasks)
  let l:database = shellescape(a:database)
  let l:cmd = shellescape('let g:kronos_tasks = ' . string(a:tasks))

  call system('echo ' . l:cmd . '>' . l:database)
  return 1
endfunction

