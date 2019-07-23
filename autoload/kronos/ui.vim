let s:assign = function('kronos#utils#assign')
let s:compose = function('kronos#utils#compose')
let s:sum = function('kronos#utils#sum')
let s:trim = function('kronos#utils#trim')
let s:approx_due = function('kronos#utils#date#approx_due')
let s:parse_due = function('kronos#utils#date#parse_due')
let s:worktime = function('kronos#utils#date#worktime')
let s:duration = function('kronos#utils#date#duration')
let s:log_error = function('kronos#utils#log#error')
let s:match_one = function('kronos#utils#match_one')

let s:max_widths = []
let s:buff_name = 'Kronos'

" ------------------------------------------------------------------- # Config #

let s:config = {
  \'info': {
    \'columns': ['key', 'value'],
    \'keys': ['id', 'desc', 'tags', 'active', 'due', 'done', 'worktime'],
  \},
  \'list': {
    \'columns': ['id', 'desc', 'tags', 'active', 'due'],
  \},
  \'worktime': {
    \'columns': ['date', 'worktime'],
  \},
  \'labels': {
    \'active': 'ACTIVE',
    \'date': 'DATE',
    \'desc': 'DESC',
    \'done': 'DONE',
    \'due': 'DUE',
    \'id': 'ID',
    \'key': 'KEY',
    \'tags': 'TAGS',
    \'total': 'TOTAL',
    \'value': 'VALUE',
    \'worktime': 'WORKTIME',
  \},
\}

" --------------------------------------------------------------------- # Info #

function! kronos#ui#info()
  let task = s:get_focused_task()
  let task = kronos#task#to_info_string(task)
  let lines = map(
    \copy(s:config.info.keys),
    \'{"key": s:config.labels[v:val], "value": task[v:val]}',
  \)

  silent! bwipeout 'Kronos Info'
  silent! botright new Kronos Info

  call append(0, s:render('info', lines))
  normal! ddgg
  setlocal filetype=kinfo
endfunction

" --------------------------------------------------------------------- # List #

function! kronos#ui#list()
  let prev_pos = getpos('.')

  call s:refresh_buff_name()
  let tasks = kronos#task#list()
  let lines = map(copy(tasks), 'kronos#task#to_list_string(v:val)')

  redir => buf_list | silent! ls | redir END
  execute 'silent! edit ' . s:buff_name

  if match(buf_list, '"Kronos') > -1
    execute '0,$d'
  endif

  call append(0, s:render('list', lines))
  execute '$d'
  call setpos('.', prev_pos)
  setlocal filetype=klist
  let &modified = 0
  echo
endfunction

" ------------------------------------------------------------------- # Toggle #

function! kronos#ui#toggle()
  try
    let task = s:get_focused_task()
    let tasks = copy(kronos#database#read().tasks)
    let position = kronos#task#get_position(tasks, task.id)
    let tasks[position] = kronos#task#toggle(task)

    call kronos#database#write({'tasks': tasks})
    call kronos#ui#list()
  catch 'task not found'
    return s:log_error('task not found')
  catch 'task already active'
    return s:log_error('task already active')
  catch
    return s:log_error('task start failed')
  endtry
endfunction

" ------------------------------------------------------------------ # Context #

function! kronos#ui#context()
  try
    let args = input('Go to context: ')
    let g:kronos_context = split(s:trim(args), ' ')
    call kronos#ui#list()
  catch
    return s:log_error('context failed')
  endtry
endfunction

" --------------------------------------------------------- # Toggle hide done #

function! kronos#ui#hide_done()
  try
    let g:kronos_hide_done = !g:kronos_hide_done
    call kronos#ui#list()
  catch
    return s:log_error('toggle hide done failed')
  endtry
endfunction

" ----------------------------------------------------------------- # Worktime #

function! kronos#ui#worktime()
  let args = input('Worktime for: ')
  let [tags, min, max] = s:parse_worktime_args(localtime(), args)
  let tasks = kronos#task#read_all()
  let worktimes = s:worktime(localtime(), tasks, tags, min, max)

  let days  = s:compose('sort', 'keys')(worktimes)
  let total = s:compose(
    \s:duration,
    \s:sum,
    \'values'
  \)(worktimes)

  let worktimes_lines = map(
    \copy(days),
    \'{"date": v:val, "worktime": s:duration(worktimes[v:val])}',
  \)

  let empty_line = {'date': '---', 'worktime': '---'}
  let total_line = {
    \'date': s:config.labels['total'],
    \'worktime': total,
  \}

  let lines = worktimes_lines + [empty_line, total_line]

  let tags_str = empty(tags)
    \? ''
    \: join(map(copy(tags), 'printf(" +%s", v:val)'), '')

  execute 'silent! botright new Kronos Worktime' . tags_str

  call append(0, s:render('worktime', lines))
  normal! ddgg
  setlocal filetype=kwtime
  echo
endfunction

function s:parse_worktime_args(date_ref, args)
  let args = split(s:trim(a:args), ' ')

  let min  = -1
  let max  = -1
  let tags = []

  for arg in args
    if arg =~ '^>\w*'
      let min = s:approx_due_strict(a:date_ref, arg)
    elseif arg =~ '^<\w*'
      let max = s:approx_due_strict(a:date_ref, arg)
    else
      call add(tags, arg)
    endif
  endfor

  return [tags, min, max]
endfunction

" ---------------------------------------------------------- # Cell management #

function! kronos#ui#select_next_cell()
  normal! f|l

  if col('.') == col('$') - 1
    if line('.') == line('$')
      normal! T|
    else
      normal! j0l
    endif
  endif
endfunction

function! kronos#ui#select_prev_cell()
  if col('.') == 2 && line('.') > 2
    normal! k$T|
  else
    normal! 2T|
  endif
endfunction

function! kronos#ui#delete_in_cell()
  execute printf('normal! %sdt|', col('.') == 1 ? '' : 'T|')
endfunction

function! kronos#ui#change_in_cell()
  call kronos#ui#delete_in_cell()
  startinsert
endfunction

function! kronos#ui#visual_in_cell()
  execute printf('normal! %svt|', col('.') == 1 ? '' : 'T|')
endfunction

" ------------------------------------------------------------------ # Sorting #

function! s:sort_by(col, dir, t1, t2)
  if a:col == 'tags' | return 0 | endif
  if (a:t1[a:col] < a:t2[a:col]) | return -1 * a:dir
  elseif (a:t1[a:col] > a:t2[a:col]) | return 1 * a:dir
  else | return 0 | endif
endfunction

function kronos#ui#sort(dir)
  let tasks  = kronos#database#read().tasks
  let line = getline('.')
  let pos = getcurpos()[2] - 1
  let index = len(split(line[pos:], '|'))
  let index = index == 0 ? 1 : index
  let col = s:config.list.columns[len(s:config.list.columns) - index]
  let sorted_tasks = sort(copy(tasks), {a, b -> s:sort_by(col, a:dir, a, b)})

  call kronos#database#write({'tasks': sorted_tasks})
  call kronos#ui#list()
  let &modified = 1
endfunction

" -------------------------------------------------------------- # Parse utils #

function kronos#ui#parse_buffer()
  let prev_tasks  = kronos#database#read().tasks
  let next_tasks  = map(getline(2, '$'), 's:parse_buffer_line(v:key, v:val)')

  let prev_tasks_id = map(copy(prev_tasks), 'v:val.id')
  let next_tasks_id = map(filter(copy(next_tasks), "has_key(v:val, 'id')"), 'v:val.id')
  let tasks_id = uniq(prev_tasks_id + next_tasks_id)

  " Update existing tasks and create new ones
  for i in range(len(next_tasks))
    let next_task = next_tasks[i]

    if !has_key(next_task, 'id')
      let next_tasks[i] = kronos#task#create(tasks_id, next_task)
      let tasks_id += [next_tasks[i].id]
    elseif !s:exists_in(prev_tasks_id, next_task.id)
      let next_tasks[i] = kronos#task#create(prev_tasks_id, next_task)
      let tasks_id += [next_tasks[i].id]
    else
      let prev_task_index = index(prev_tasks_id, next_task.id)
      let next_tasks[i] = kronos#task#update(
        \prev_tasks[prev_task_index],
        \next_task
      \)
    endif
  endfor

  " Mark as done or delete missing ones
  for prev_task in prev_tasks
    if s:exists_in(next_tasks_id, prev_task.id) | continue | endif
    if !s:match_one(prev_task.tags, g:kronos_context)
      call add(next_tasks, prev_task) | continue
    endif

    if g:kronos_hide_done || !prev_task.done
      call add(next_tasks, kronos#task#done(prev_task))
    endif
  endfor

  call kronos#database#write({'tasks': uniq(next_tasks, 's:uniq_by_id')})
  call kronos#ui#list()
  let &modified = 0
endfunction

function s:uniq_by_id(a, b)
  if a:a.id > a:b.id | return 1
  elseif a:a.id < a:b.id | return -1
  else | return 0 | endif
endfunction

function s:parse_buffer_line(index, line)
  if match(a:line, '^|-\=\d\{-1,}\s\{-}|.*|.\{-}|.\{-}|.\{-}|$') == -1
    let [desc, tags, due] = s:parse_args(localtime(), s:trim(a:line))

    return {
      \'desc': desc,
      \'tags': tags,
      \'due': due,
      \'active': 0,
      \'start': [],
      \'stop': [],
      \'done': 0,
    \}
  else
    let cells = split(a:line, '|')
    let id = +s:trim(cells[0])
    let desc = s:trim(join(cells[1:-4], ''))
    let tags = split(s:trim(cells[-3]), ' ')
    let due = s:trim(cells[-1])

    try
      let task = kronos#task#read(id)
    catch
      let task = {
        \'desc': desc,
        \'tags': tags,
        \'due': due,
        \'active': 0,
        \'start': [],
        \'stop': [],
        \'done': 0,
      \}

      if id | let task.id = id | endif
      return task
    endtry

    if match(due, '^\s*:') == -1
      if cells[-1] != '' | let due = task.due
      else | let due = 0 | endif
    else
      let due = s:approx_due(localtime(), due)
    endif

    return s:assign(task, {
      \'desc': desc,
      \'tags': tags,
      \'due': due,
    \})
  endif
endfunction

function! s:parse_args(date_ref, args)
  let args = split(a:args, ' ')

  let desc     = []
  let due      = 0
  let tags     = []
  let tags_old = []
  let tags_new = []

  for arg in args
    if arg =~ '^+\w'
      call add(tags_new, arg[1:])
    elseif arg =~ '^-\w'
      call add(tags_old, arg[1:])
    elseif arg =~ '^:\w*'
      let due = s:approx_due(a:date_ref, arg)
    else
      call add(desc, arg)
    endif
  endfor

  for tag in tags_new
    if index(tags, tag) == -1 | call add(tags, tag) | endif
  endfor

  for tag in tags_old
    let index = index(tags, tag)
    if  index != -1 | call remove(tags, index) | endif
  endfor

  return [join(desc, ' '), tags, due]
endfunction

" ------------------------------------------------------------------ # Renders #

function! s:render(type, lines)
  let s:max_widths = s:get_max_widths(a:lines, s:config[a:type].columns)
  let header = [s:render_line(s:config.labels, s:max_widths, a:type)]
  let line = map(copy(a:lines), 's:render_line(v:val, s:max_widths, a:type)')

  return header + line
endfunction

function! s:render_line(line, max_widths, type)
  return '|' . join(map(
    \copy(s:config[a:type].columns),
    \'s:render_cell(a:line[v:val], a:max_widths[v:key])',
  \), '')
endfunction

function! s:render_cell(cell, max_width)
  let cell_width = strdisplaywidth(a:cell[:a:max_width])
  return a:cell[:a:max_width] . repeat(' ', a:max_width - cell_width) . ' |'
endfunction

" -------------------------------------------------------------------- # Utils #

function! s:get_max_widths(tasks, columns)
  let max_widths = map(copy(a:columns), 'strlen(s:config.labels[v:val])')

  for task in a:tasks
    let widths = map(copy(a:columns), 'strlen(task[v:val])')
    call map(max_widths, 'max([widths[v:key], v:val])')
  endfor

  return max_widths
endfunction

function! s:get_focused_task()
  let tasks = kronos#task#list()
  let index = line('.') - 2
  if  index == -1 | throw 'task not found' | endif

  return get(tasks, index)
endfunction

function! s:refresh_buff_name()
  let buff_name = 'Kronos'

  if !g:kronos_hide_done
    let buff_name .= '*'
  endif

  if len(g:kronos_context) > 0
    let tags = map(copy(g:kronos_context), 'printf(" +%s", v:val)')
    let buff_name .= join(tags, '')
  endif

  if buff_name != s:buff_name
    execute 'silent! enew'
    execute 'silent! bwipeout ' . s:buff_name
    let s:buff_name = buff_name
  endif
endfunction

function! s:exists_in(list, item)
  return index(a:list, a:item) > -1
endfunction
