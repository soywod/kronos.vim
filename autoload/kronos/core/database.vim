" -------------------------------------------------------------------- # Purge #

function! kronos#core#database#Purge(database)
  if filereadable(a:database)
    call delete(a:database)
  endif
endfunction

" --------------------------------------------------------------------- # Read #

function! kronos#core#database#Read(database)
  return filereadable(a:database)
    \? map(readfile(a:database), 'eval(v:val)')
    \: []
endfunction

" -------------------------------------------------------------------- # Write #

function! kronos#core#database#Write(database, tasks)
  let tasksdone   = filter(copy(a:tasks), 'v:val.done')
  let tasksundone = filter(copy(a:tasks), '! v:val.done')

  let data = map(tasksundone + tasksdone, 'string(v:val)')
  call writefile(data, a:database, 's')

  if g:kronos_enable_gist
    call kronos#integration#gist#Write(join(data, "\n"))
  endif
endfunction

