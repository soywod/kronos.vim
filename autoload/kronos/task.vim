function! kronos#task#Create(database, task)
  let l:tasks = kronos#database#ReadTasks(a:database)
  let a:task.id = kronos#task#GenerateId(l:tasks)

  call add(l:tasks, a:task)
  call kronos#database#WriteTasks(a:database, l:tasks)

  return a:task.id
endfunction

function! kronos#task#Read(database, id)
  let l:tasks = kronos#database#ReadTasks(a:database)
  let l:index = kronos#task#GetTaskIndexById(l:tasks, a:id)

  return l:tasks[l:index]
endfunction

function! kronos#task#ReadAll(database)
  return kronos#database#ReadTasks(a:database)
endfunction

function! kronos#task#Update(database, id, task)
  let l:tasks = kronos#database#ReadTasks(a:database)
  let l:index = kronos#task#GetTaskIndexById(l:tasks, a:id)

  let l:tasks[l:index] = a:task
  call kronos#database#WriteTasks(a:database, l:tasks)

  return 1
endfunction

function! kronos#task#Delete(database, id)
  let l:tasks = kronos#database#ReadTasks(a:database)
  let l:index = kronos#task#GetTaskIndexById(l:tasks, a:id)

  call remove(l:tasks, l:index)
  call kronos#database#WriteTasks(a:database, l:tasks)

  return 1
endfunction

"--------------------------------------------------------------------" Helpers "

function! kronos#task#GenerateId(tasks)
  let l:newid = 1
  let l:ids = copy(a:tasks)

  call map(l:ids, 'v:val.id')

  while index(l:ids, l:newid) != -1
    let l:newid += 1
  endwhile

  return l:newid
endfunction

function! kronos#task#GetTaskIndexById(tasks, id)
  let l:index = 0

  for l:task in a:tasks
    if l:task.id == a:id
      return l:index
    endif

    let l:index += 1
  endfor

  throw 'task-not-found'
endfunction

