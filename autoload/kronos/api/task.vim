"----------------------------------------------------------------# Create task #

function! kronos#api#task#Create(database, task)
  let l:tasks = kronos#api#database#ReadTasks(a:database)
  let l:task = copy(a:task)
  let l:task.id = kronos#tool#task#GenerateId(l:tasks)

  call add(l:tasks, l:task)
  call kronos#api#database#WriteTasks(a:database, l:tasks)

  return l:task.id
endfunction

"------------------------------------------------------------------# Read task #

function! kronos#api#task#Read(database, id)
  let l:tasks = kronos#api#database#ReadTasks(a:database)
  let l:index = kronos#tool#task#GetTaskIndexById(l:tasks, a:id)

  return l:tasks[l:index]
endfunction

"-------------------------------------------------------------# Read all tasks #

function! kronos#api#task#ReadAll(database)
  return kronos#api#database#ReadTasks(a:database)
endfunction

"----------------------------------------------------------------# Update task #

function! kronos#api#task#Update(database, id, task)
  let l:tasks = kronos#api#database#ReadTasks(a:database)
  let l:index = kronos#tool#task#GetTaskIndexById(l:tasks, a:id)

  let l:tasks[l:index] = a:task
  call kronos#api#database#WriteTasks(a:database, l:tasks)
endfunction

"----------------------------------------------------------------# Delete task #

function! kronos#api#task#Delete(database, id)
  let l:tasks = kronos#api#database#ReadTasks(a:database)
  let l:index = kronos#tool#task#GetTaskIndexById(l:tasks, a:id)

  call remove(l:tasks, l:index)
  call kronos#api#database#WriteTasks(a:database, l:tasks)
endfunction

