" ------------------------------------------------------------------- # Create #

function! kronos#core#task#Create(database, task)
  let tasks   = kronos#core#database#Read(a:database)
  let task    = copy(a:task)
  let task.id = kronos#tool#task#GenerateId(tasks)

  let newtasks = add(copy(tasks), task)
  call kronos#core#database#Write(a:database, newtasks)

  return task.id
endfunction

" --------------------------------------------------------------------- # Read #

function! kronos#core#task#Read(database, id)
  let tasks = copy(kronos#core#database#Read(a:database))
  let index = kronos#tool#task#GetIndexById(tasks, a:id)

  return tasks[index]
endfunction

" ----------------------------------------------------------------- # Read all #

function! kronos#core#task#ReadAll(database)
  return kronos#core#database#Read(a:database)
endfunction

" ------------------------------------------------------------------- # Update #

function! kronos#core#task#Update(database, id, task)
  let newtasks = copy(kronos#core#database#Read(a:database))
  let index    = kronos#tool#task#GetIndexById(newtasks, a:id)

  let newtasks[index] = copy(a:task)
  call kronos#core#database#Write(a:database, newtasks)
endfunction

" ------------------------------------------------------------------- # Delete #

function! kronos#core#task#Delete(database, id)
  let newtasks = copy(kronos#core#database#Read(a:database))
  let index    = kronos#tool#task#GetIndexById(newtasks, a:id)

  call remove(newtasks, index)
  call kronos#core#database#Write(a:database, newtasks)
endfunction

