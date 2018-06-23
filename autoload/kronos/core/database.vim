" -------------------------------------------------------------------- # Purge #

function! kronos#core#database#Purge(database)
  if exists('s:cache') | unlet s:cache | endif
  if filereadable(a:database) | call delete(a:database) | endif
endfunction

" --------------------------------------------------------------------- # Read #

function! kronos#core#database#Read(database)
  if exists('s:cache') | return s:cache | endif

  let s:cache = filereadable(a:database)
    \? map(readfile(a:database), 'eval(v:val)')
    \: []

  return s:cache
endfunction

" -------------------------------------------------------------------- # Write #

function! kronos#core#database#Write(database, tasks)
  let tasksdone   = filter(copy(a:tasks), 'v:val.done')
  let tasksundone = filter(copy(a:tasks), '! v:val.done')

  let s:cache = tasksundone + tasksdone
  let data    = map(copy(s:cache), 'string(v:val)')

  call writefile(data, a:database, 's')
endfunction

