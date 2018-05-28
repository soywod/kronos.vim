function! kronos#ReadTasks(database)
  if ! filereadable(a:database)
    call s:WriteTasks(a:database, [])
    return []
  endif

  call execute('source ' . a:database)
  return g:kronos_tasks
endfunction

function! kronos#WriteTasks(database, tasks)
  let l:database = shellescape(a:database)
  let l:cmd = shellescape('let g:kronos_tasks = ' . string(a:tasks))

  call system('echo ' . l:cmd . '>' . l:database)
endfunction

