"----------------------------------------------------------------# Create task #

function! kronos#api#task#Create(database, task)
  let l:tasks    = kronos#api#database#Read(a:database)
  let l:task     = copy(a:task)
  let l:task.id  = kronos#tool#task#GenerateId(l:tasks)
  let l:newtasks = add(copy(l:tasks), l:task)

  call kronos#api#database#Write(a:database, l:newtasks)
  return l:task.id
endfunction

"------------------------------------------------------------------# Read task #

function! kronos#api#task#Read(database, id)
  let l:tasks = copy(kronos#api#database#Read(a:database))
  let l:index = kronos#tool#task#GetIndexById(l:tasks, a:id)

  return l:tasks[l:index]
endfunction

"-------------------------------------------------------------# Read all tasks #

function! kronos#api#task#ReadAll(database)
  return kronos#api#database#Read(a:database)
endfunction

"----------------------------------------------------------------# Update task #

function! kronos#api#task#Update(database, id, task)
  let l:newtasks          = copy(kronos#api#database#Read(a:database))
  let l:index             = kronos#tool#task#GetIndexById(l:newtasks, a:id)
  let l:newtasks[l:index] = copy(a:task)

  call kronos#api#database#Write(a:database, l:newtasks)
endfunction

"----------------------------------------------------------------# Delete task #

function! kronos#api#task#Delete(database, id)
  let l:newtasks = copy(kronos#api#database#Read(a:database))
  let l:index    = kronos#tool#task#GetIndexById(l:newtasks, a:id)

  call remove(l:newtasks, l:index)
  call kronos#api#database#Write(a:database, l:newtasks)
endfunction

