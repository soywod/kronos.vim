" ------------------------------------------------------------------- # Config #

let s:config = {
  \'info': {
    \'columns': ['key', 'value'],
    \'keys': ['id', 'desc', 'tags', 'active', 'last_active', 'due', 'worktime', 'done'],
  \},
  \'list': {
    \'columns': ['id', 'desc', 'tags', 'active', 'due'],
  \},
  \'labels': {
    \'active': 'ACTIVE',
    \'desc': 'DESC',
    \'done': 'DONE',
    \'due': 'DUE',
    \'id': 'ID',
    \'key': 'KEY',
    \'last_active': 'LAST ACTIVE',
    \'tags': 'TAGS',
    \'value': 'VALUE',
    \'worktime': 'WORKTIME',
  \},
\}

let s:max_widths = []
let s:buff_name = 'Kronos'

let s:compose = function('kronos#utils#compose')

" --------------------------------------------------------------------- # Info #

function! kronos#interface#gui#info()
  let id = s:get_focused_task_id()
  let task = s:compose('kronos#task#to_info_string', 'kronos#task#read')(id)
  let lines = map(
    \copy(s:config.info.keys),
    \'{"key": s:config.labels[v:val], "value": task[v:val]}',
  \)

  silent! bdelete 'Kronos Info'
  silent! botright new Kronos Info

  call append(0, s:render('info', lines))
  normal! ddgg
  setlocal filetype=kinfo
endfunction

" --------------------------------------------------------------------- # List #

function! kronos#interface#gui#list()
  let prevpos = getpos('.')

  let tasks = kronos#interface#common#list()
  let lines = map(copy(tasks), 'kronos#task#to_list_string(v:val)')

  redir => buflist | silent! ls | redir END
  execute 'silent! edit ' . s:buff_name

  if match(buflist, '"Kronos') > -1
    execute '0,$d'
  endif

  call append(0, s:render('list', lines))
  execute '$d'
  call setpos('.', prevpos)
  setlocal filetype=klist
  let &modified = 0
endfunction

" -------------------------------------------------------------------- # Start #

function! kronos#interface#gui#start()
  try
    let id = s:get_focused_task_id()
    call kronos#interface#common#start(localtime(), id)
    call kronos#interface#gui#list()
  catch 'task not found'
    return kronos#utils#log#error('task not found')
  catch 'task already active'
    return kronos#utils#log#error('task already active')
  catch
    return kronos#utils#log#error('task start failed')
  endtry
endfunction

" --------------------------------------------------------------------- # Stop #

function! kronos#interface#gui#stop()
  try
    let id = s:get_focused_task_id()
    call kronos#interface#common#stop(localtime(), id)
    call kronos#interface#gui#list()
  catch 'task not found'
    return kronos#utils#log#error('task not found')
  catch 'task already stopped'
    return kronos#utils#log#error('task already stopped')
  catch
    return kronos#utils#log#error('task stop failed')
  endtry
endfunction

" ------------------------------------------------------------------- # Toggle #

function! kronos#interface#gui#toggle()
  if &modified
    return kronos#utils#log#error('buffer not saved')
  endif

  try
    let id = s:get_focused_task_id()
    let task = kronos#task#read(id)

    return task.active
      \? kronos#interface#gui#stop()
      \: kronos#interface#gui#start()
  catch 'task not found'
    return kronos#utils#log#error('task not found')
  catch
    return kronos#utils#log#error('task toggle failed')
  endtry
endfunction

" ------------------------------------------------------------------ # Context #

function! kronos#interface#gui#context()
  try
    let args = input('Go to context: ')
    call kronos#interface#common#context(args)

    execute 'silent! bdelete ' . s:buff_name

    if (len(g:kronos_context) == 0)
      let s:buff_name = 'Kronos'
    else
      let tags = map(copy(g:kronos_context), 'printf("+%s", v:val)')
      let s:buff_name = printf('Kronos [%s]', join(tags, ' '))
    endif

    echo
    call kronos#interface#gui#list()
  catch
    return kronos#utils#log#error('task context failed')
  endtry
endfunction

" --------------------------------------------------------- # Toggle hide done #

function! kronos#interface#gui#toggle_hide_done()
  try
    let g:kronos_hide_done = ! g:kronos_hide_done
    call kronos#interface#gui#list()
  catch
    return kronos#utils#log#error('task toggle hide done failed')
  endtry
endfunction

" ---------------------------------------------------------- # Cell management #

function! kronos#interface#gui#select_next_cell()
  normal! f|l

  if col('.') == col('$') - 1
    if line('.') == line('$')
      normal! T|
    else
      normal! j0l
    endif
  endif
endfunction

function! kronos#interface#gui#select_prev_cell()
  if col('.') == 2 && line('.') > 2
    normal! k$T|
  else
    normal! 2T|
  endif
endfunction

function! kronos#interface#gui#delete_in_cell()
  execute printf('normal! %sdt|', col('.') == 1 ? '' : 'T|')
endfunction

function! kronos#interface#gui#change_in_cell()
  call kronos#interface#gui#delete_in_cell()
  startinsert
endfunction

function! kronos#interface#gui#visual_in_cell()
  execute printf('normal! %svt|', col('.') == 1 ? '' : 'T|')
endfunction

" ------------------------------------------------------------- # Parse buffer #

function s:parse_buffer_line(index, line)
  if match(a:line, '^|\d\{-1,}\s\{-}|.*|.\{-}|.\{-}|.\{-}|$') == -1
    let [desc, tags, due] =
      \kronos#interface#common#parse_args(localtime(), kronos#utils#trim(a:line), {})

    return {
      \'desc': desc,
      \'tags': tags,
      \'due': due,
      \'active': 0,
      \'last_active': 0,
      \'worktime': 0,
      \'done': 0,
    \}
  else
    let cells = split(a:line, '|')
    let id = kronos#utils#trim(cells[0])
    let desc = kronos#utils#trim(join(cells[1:-4], ''))
    let tags = split(kronos#utils#trim(cells[-3]), ' ')
    let due = kronos#utils#trim(cells[-1])

    try
      let task = kronos#task#read(id)
    catch
      let task = {
        \'desc': desc,
        \'tags': tags,
        \'due': due,
        \'active': 0,
        \'last_active': 0,
        \'worktime': 0,
        \'done': 0,
      \}

      if id | let task.id = id | endif
      return task
    endtry

    if match(due, '^\s*:') == -1
      if cells[-1] != '' | let due = task.due
      else | let due = 0 | endif
    else
      let due = kronos#utils#datetime#parse_due(localtime(), due)
    endif

    return kronos#utils#assign(task, {
      \'desc': desc,
      \'tags': tags,
      \'due': due,
    \})
  endif
endfunction

function kronos#interface#gui#parse_buffer()
  let tasks_old = kronos#interface#common#list()
  let tasks_new = map(getline(2, '$'), 's:parse_buffer_line(v:key, v:val)')

  let task_old_ids = map(copy(tasks_old), 'v:val.id')
  let task_new_ids = map(
    \filter(copy(tasks_new), 'has_key(v:val, ''id'')'),
    \'v:val.id',
  \)

  for task in tasks_old
    if index(task_new_ids, task.id) > -1 | continue | endif
    call kronos#interface#common#done(localtime(), task.id)
  endfor

  for task in tasks_new
    if !has_key(task, 'id')
      call kronos#task#create(task)
      continue
    endif

    let index = index(task_old_ids, task.id)
    if  index > -1 && task == tasks_old[index] | continue | endif

    if index == -1
      call kronos#task#create(task)
    else
      call kronos#task#update(task.id, task)
    endif
  endfor

  call kronos#interface#gui#list()
  let &modified = 0
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

function! s:get_focused_task_id()
  let tasks = kronos#interface#common#list()
  let index = line('.') - 2
  if  index == -1 | throw 'task not found' | endif

  return +get(tasks, index).id
endfunction
