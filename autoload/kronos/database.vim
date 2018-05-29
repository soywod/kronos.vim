function! kronos#database#ReadTasks(database)
  if ! filereadable(a:database)
    call kronos#database#WriteTasks(a:database, [])
    return []
  endif

  try
    execute 'source ' . a:database
    return g:kronos_tasks
  finally
    unlet g:kronos_tasks
  endtry
endfunction

function! kronos#database#WriteTasks(database, tasks)
  let l:database = shellescape(a:database)
  let l:basecmd = 'let g:kronos_tasks = '
  let l:cmd = shellescape(l:basecmd . string(a:tasks))

  call system('echo ' . l:cmd . '>' . l:database)
  return 1
endfunction

