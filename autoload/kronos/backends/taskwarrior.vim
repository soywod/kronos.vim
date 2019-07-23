function! kronos#backends#taskwarrior#create(task)
  let tags = join(map(copy(a:task.tags), "'+' . v:val"), ' ')
  let desc = shellescape(a:task.desc)
  let due = a:task.due ? strftime('%Y-%m-%dT%H:%M:%S', a:task.due) : ''

  let command = join([
    \'task', 'add',
    \desc,
    \tags,
    \'due:' . due,
  \], ' ')

  return matchstr(system(command), '\d\+')
endfunction

function! kronos#backends#taskwarrior#update(prev_task, task)
  let prev_tags = join(map(copy(a:prev_task.tags), "'-' . v:val"), ' ')
  let tags = join(map(copy(a:task.tags), "'+' . v:val"), ' ')
  let desc = shellescape(a:task.desc)
  let due = a:task.due ? strftime('%Y-%m-%dT%H:%M:%S', a:task.due) : ''

  let cmd = join([
    \'task', 'modify',
    \a:task.id,
    \desc,
    \prev_tags,
    \tags,
    \'due:' . due,
  \], ' ')

  call system(cmd)
endfunction

function! kronos#backends#taskwarrior#toggle(task)
  let action = a:task.active ? 'stop' : 'start'
  let command = join(['task', action, a:task.id], ' ')

  call system(command)
endfunction

function! kronos#backends#taskwarrior#done(id)
  let command = join(['task', 'done', a:id], ' ')
  call system(command)
endfunction
