"-----------------------------------------------------------------------" CRUD "

function! kronos#task#Create(database, task)
  let l:tasks = kronos#database#ReadTasks(a:database)

  call add(l:tasks, a:task)
  call kronos#database#WriteTasks(a:database, l:tasks)
endfunction

function! kronos#task#Read(database, id)
  let l:tasks = kronos#database#ReadTasks(a:database)
  let l:index = s:GetTaskById(l:tasks, a:id)

  return l:tasks[l:index]
endfunction

function! kronos#task#ReadAll(database)
  return kronos#database#ReadTasks(a:database)
endfunction

function! kronos#task#Update(database, task)
  let l:tasks = kronos#database#ReadTasks(a:database)
  let l:index = s:GetTaskById(l:tasks, a:task.id)

  let l:tasks[l:index] = a:task
  call kronos#database#WriteTasks(a:database, l:tasks)

  return v:true
endfunction

function! kronos#task#Delete(database, id)
  let l:tasks = kronos#database#ReadTasks(a:database)
  let l:index = s:GetTaskById(l:tasks, a:id)

  call remove(l:tasks, l:index)
  call kronos#database#WriteTasks(a:database, l:tasks)

  return v:true
endfunction

"--------------------------------------------------------------------" Helpers "

function! s:GetTaskById(tasks, id)
  let l:index = 0

  for l:task in a:tasks
    if l:task.id == a:id
      return l:index
    endif

    let l:index += 1
  endfor

  throw 'task-not-found'
endfunction

