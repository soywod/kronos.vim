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

" ----------------------------------------------------- # Format task for info #

function! kronos#tool#task#ToInfoString(task)
  let task = copy(a:task)

  let Date     = function('kronos#tool#datetime#PrintDate')
  let Interval = function('kronos#tool#datetime#PrintInterval')

  let wtimestr = task.active
    \? Interval(task.worktime + localtime() - task.active)
    \: task.worktime ? Interval(task.worktime) : ''

  let task.active     = task.active     ? Date(task.active)     : ''
  let task.done       = task.done       ? Date(task.done)       : ''
  let task.due        = task.due        ? Date(task.due)        : ''
  let task.lastactive = task.lastactive ? Date(task.lastactive) : ''

  let task.worktime   = wtimestr
  let task.tags       = join(task.tags, ' ')

  return task
endfunction

" ----------------------------------------------------- # Format task for list #

function! kronos#tool#task#ToListString(task)
  let task = copy(a:task)

  let DateDiff = function('kronos#tool#datetime#PrintDiff', [localtime()])
  let Interval = function('kronos#tool#datetime#PrintInterval')

  let task.id         = task.done       ? '-'                       : task.id
  let task.active     = task.active     ? DateDiff(task.active)     : ''
  let task.done       = task.done       ? DateDiff(task.done)       : ''
  let task.due        = task.due        ? DateDiff(task.due)        : ''
  let task.lastactive = task.lastactive ? DateDiff(task.lastactive) : ''
  let task.worktime   = task.worktime   ? Interval(task.worktime)   : ''

  let task.tags = join(task.tags, ' ')

  return task
endfunction

