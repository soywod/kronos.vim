" ------------------------------------------------------------------- # Create #

function! kronos#api#task#Create(database, task)
  let tasks   = kronos#api#database#Read(a:database)
  let task    = copy(a:task)
  let task.id = kronos#tool#task#GenerateId(tasks)

  let newtasks = add(copy(tasks), task)
  call kronos#api#database#Write(a:database, newtasks)

  return task.id
endfunction

" --------------------------------------------------------------------- # Read #

function! kronos#api#task#Read(database, id)
  let tasks = copy(kronos#api#database#Read(a:database))
  let index = kronos#tool#task#GetIndexById(tasks, a:id)

  return tasks[index]
endfunction

" ----------------------------------------------------------------- # Read all #

function! kronos#api#task#ReadAll(database)
  return kronos#api#database#Read(a:database)
endfunction

" ------------------------------------------------------------------- # Update #

function! kronos#api#task#Update(database, id, task)
  let newtasks = copy(kronos#api#database#Read(a:database))
  let index    = kronos#tool#task#GetIndexById(newtasks, a:id)

  let newtasks[index] = copy(a:task)
  call kronos#api#database#Write(a:database, newtasks)
endfunction

" ------------------------------------------------------------------- # Delete #

function! kronos#api#task#Delete(database, id)
  let newtasks = copy(kronos#api#database#Read(a:database))
  let index    = kronos#tool#task#GetIndexById(newtasks, a:id)

  call remove(newtasks, index)
  call kronos#api#database#Write(a:database, newtasks)
endfunction

