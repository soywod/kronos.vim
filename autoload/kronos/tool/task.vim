" -------------------------------------------------------------- # Generate ID #

function! kronos#tool#task#GenerateId(tasks)
  let l:newid = 1
  let l:ids   = map(copy(a:tasks), 'v:val.id')

  while index(l:ids, l:newid) != -1
    let l:newid += 1
  endwhile

  return l:newid
endfunction

" ---------------------------------------------------------- # Get index by ID #

function! kronos#tool#task#GetIndexById(tasks, id)
  let l:index = 0

  for l:task in a:tasks
    if  l:task.id == a:id | return l:index | endif
    let l:index += 1
  endfor

  throw 'task-not-found'
endfunction

