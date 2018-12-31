" ------------------------------------------------------------------- # Config #

let s:config = {
  \'info': {
    \'columns': ['key', 'value'],
    \'keys': ['id', 'desc', 'tags', 'active', 'due', 'done'],
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

let s:max_widths = []
let s:buff_name = 'Kronos'

let s:compose = function('kronos#utils#compose')
let s:date_interval = function('kronos#utils#date_interval')

" --------------------------------------------------------------------- # Info #

function! kronos#ui#info()
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

function! kronos#ui#list()
  let prevpos = getpos('.')

  let tasks = kronos#task#list()
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
  echo
endfunction

" ------------------------------------------------------------------- # Toggle #

function! kronos#ui#toggle()
  try
    let id = s:get_focused_task_id()
    call kronos#sync#send({
      \'type': 'update',
      \'task_id': id,
      \'task': kronos#task#toggle(id),
    \})
    call kronos#ui#list()
  catch 'task not found'
    return kronos#utils#error_log('task not found')
  catch 'task already active'
    return kronos#utils#error_log('task already active')
  catch
    return kronos#utils#error_log('task start failed')
  endtry
endfunction

" ------------------------------------------------------------------ # Context #

function! kronos#ui#context()
  try
    let args = input('Go to context: ')
    let g:kronos_context = split(kronos#utils#trim(args), ' ')

    call s:refresh_buff_name()
    call kronos#ui#list()
  catch
    return kronos#utils#error_log('task context failed')
  endtry
endfunction

" --------------------------------------------------------- # Toggle hide done #

function! kronos#ui#toggle_hide_done()
  try
    let g:kronos_hide_done = !g:kronos_hide_done

    call s:refresh_buff_name()
    call kronos#ui#list()
  catch
    return kronos#utils#error_log('task toggle hide done failed')
  endtry
endfunction

" ----------------------------------------------------------------- # Worktime #

function! kronos#ui#worktime()
  let args = input('Worktime for: ')
  let tags = split(kronos#utils#trim(args), ' ')
  let tasks = kronos#task#read_all()
  let worktimes = kronos#utils#worktime(tasks, tags, localtime())

  let days  = s:compose('sort', 'keys')(worktimes)
  let total = s:compose(
    \'kronos#utils#date_interval',
    \'kronos#utils#sum',
    \'values'
  \)(worktimes)

  let worktimes_lines = map(
    \copy(days),
    \'{"date": v:val, "worktime": s:date_interval(worktimes[v:val])}',
  \)

  let empty_line = {'date': '---', 'worktime': '---'}
  let total_line = {
    \'date': s:config.labels['total'],
    \'worktime': total,
  \}

  let lines = worktimes_lines + [empty_line, total_line]

  silent! bdelete 'Kronos Worktime'
  silent! botright new Kronos Worktime

  call append(0, s:render('worktime', lines))
  normal! ddgg
  setlocal filetype=kwtime
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

" -------------------------------------------------------------- # Parse utils #

function kronos#ui#parse_buffer()
  let tasks_old = kronos#task#list()
  let tasks_new = map(getline(2, '$'), 's:parse_buffer_line(v:key, v:val)')

  let task_old_ids = map(copy(tasks_old), 'v:val.id')
  let task_new_ids = map(
    \filter(copy(tasks_new), 'has_key(v:val, ''id'')'),
    \'v:val.id',
  \)

  for task in tasks_old
    if index(task_new_ids, task.id) > -1 | continue | endif
    if task.done
      call kronos#sync#send({
        \'type': 'delete',
        \'task_index': kronos#task#delete(task.id),
      \})
    else
      call kronos#sync#send({
        \'type': 'update',
        \'task_id': task.id,
        \'task': kronos#task#done(task.id),
      \})
    endif
  endfor

  for task in tasks_new
    if !has_key(task, 'id')
      call kronos#sync#send({
        \'type': 'create',
        \'task': kronos#task#create(task),
      \})
      continue
    endif

    let index = index(task_old_ids, task.id)
    if  index > -1 && task == tasks_old[index] | continue | endif

    if index == -1
      call kronos#sync#send({
        \'type': 'create',
        \'task': kronos#task#create(task),
      \})
    else
      call kronos#sync#send({
        \'type': 'update',
        \'task_id': task.id,
        \'task': kronos#task#update(task.id, task),
      \})
    endif
  endfor

  call kronos#ui#list()
  let &modified = 0
endfunction

function s:parse_buffer_line(index, line)
  if match(a:line, '^|-\=\d\{-1,}\s\{-}|.*|.\{-}|.\{-}|.\{-}|$') == -1
    let [desc, tags, due] = s:parse_args(localtime(), kronos#utils#trim(a:line))

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
    let id = +kronos#utils#trim(cells[0])
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
      let due = kronos#utils#parse_due(localtime(), due)
    endif

    return kronos#utils#assign(task, {
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
      let due = kronos#utils#parse_due(a:date_ref, arg)
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

function! s:get_focused_task_id()
  let tasks = kronos#task#list()
  let index = line('.') - 2
  if  index == -1 | throw 'task not found' | endif

  return +get(tasks, index).id
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
    execute 'silent! bdelete ' . s:buff_name
    let s:buff_name = buff_name
  endif
endfunction
