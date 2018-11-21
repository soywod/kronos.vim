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

function! kronos#interface#gui#config()
  return s:config
endfunction

let s:body = []

" ---------------------------------------------------------------------- # Add #

function! kronos#interface#gui#add()
  try
    let args = input('New task string (:h kronos-add): ')
    if  empty(args) | throw 'operation canceled' | endif

    call kronos#interface#common#add(g:kronos_database, localtime(), args)
    call kronos#interface#gui#list()
  catch 'operation canceled'
    return kronos#utils#log#error('operation canceled')
  catch 'task already exist'
    return kronos#utils#log#error('task already exist')
  catch
    return kronos#utils#log#error('create task failed')
  endtry
endfunction

" --------------------------------------------------------------------- # Info #

function! kronos#interface#gui#info()
  try
    let id = s:get_focused_task_id()

    let columns = s:config.info.columns
    let keys    = s:config.info.keys
    let labels  = s:config.labels

    let headers = [filter(copy(s:config.labels), 'index(columns, v:key) + 1')]
    let headers = map(copy(headers), function('s:print_info_header'))

    let task = kronos#task#read(g:kronos_database, id)
    let task = kronos#task#to_info_string(task)
    let keys = map(
      \copy(keys),
      \'s:print_info_prop(labels[v:val], task[v:val])',
    \)

    silent! bdelete KronosInfo
    silent! botright new KronosInfo

    call append(0, headers + keys)
    normal! ddgg
    setlocal filetype=kinfo
  catch 'task not found'
    return kronos#utils#log#error('task not found')
  catch
    return kronos#utils#log#error('task info failed')
  endtry
endfunction

" --------------------------------------------------------------------- # List #

function! kronos#interface#gui#list()
  let prevpos = getpos('.')

  let tasks = kronos#interface#common#list(g:kronos_database)
  let tasks = map(copy(tasks), 'kronos#task#to_list_string(v:val)')

  silent! bdelete Kronos
  silent! edit Kronos

  call append(0, s:render(tasks))
  execute '$d'
  call setpos('.', prevpos)
  setlocal filetype=klist

endfunction

" ------------------------------------------------------------------- # Update #

function! kronos#interface#gui#update()
  try
    let args = input('Update task string (:h kronos-add): ')
    if  empty(args) | throw 'operation canceled' | endif

    let args = join([s:get_focused_task_id(), args], ' ')

    call kronos#interface#common#update(g:kronos_database, localtime(), args)
    call kronos#interface#gui#list()
  catch 'operation canceled'
    return kronos#utils#log#error('operation canceled')
  catch 'task not found'
    return kronos#utils#log#error('task not found')
  catch
    return kronos#utils#log#error('task update failed')
  endtry
endfunction

" ------------------------------------------------------------------- # Delete #

function! kronos#interface#gui#delete()
  try
    let id = s:get_focused_task_id()
    call kronos#interface#common#delete(g:kronos_database, id)
    call kronos#interface#gui#list()
  catch 'operation canceled'
    return kronos#utils#log#error('operation canceled')
  catch 'task not found'
    return kronos#utils#log#error('task not found')
  catch
    return kronos#utils#log#error('task delete failed')
  endtry
endfunction

" -------------------------------------------------------------------- # Start #

function! kronos#interface#gui#start()
  try
    let id = s:get_focused_task_id()
    call kronos#interface#common#start(g:kronos_database, localtime(), id)
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
    call kronos#interface#common#stop(g:kronos_database, localtime(), id)
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
  try
    let id   = s:get_focused_task_id()
    let task = kronos#task#read(g:kronos_database, id)

    return task.active
      \? kronos#interface#gui#stop()
      \: kronos#interface#gui#start()
  catch 'task not found'
    return kronos#utils#log#error('task not found')
  catch
    return kronos#utils#log#error('task toggle failed')
  endtry
endfunction

" --------------------------------------------------------------------- # Done #

function! kronos#interface#gui#done()
  try
    let id = s:get_focused_task_id()
    call kronos#interface#common#done(g:kronos_database, localtime(), id)
    call kronos#interface#gui#list()
  catch 'task not found'
    return kronos#utils#log#error('task not found')
  catch 'task already done'
    return kronos#utils#log#error('task already done')
  catch
    return kronos#utils#log#error('task done failed')
  endtry
endfunction

" ------------------------------------------------------------------- # Undone #

function! kronos#interface#gui#undone()
  try
    let id = s:get_focused_task_id()
    call kronos#interface#common#undone(g:kronos_database, id)
    call kronos#interface#gui#list()
  catch 'task not found'
    return kronos#utils#log#error('task not found')
  catch 'task not done'
    return kronos#utils#log#error('task not done')
  catch
    return kronos#utils#log#error('task undone failed')
  endtry
endfunction

" ------------------------------------------------------------------ # Context #

function! kronos#interface#gui#context()
  try
    let args = input('Context (:h kronos-context): ')
    call kronos#interface#common#context(args)
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

" ------------------------------------------------------------- # Parse buffer #

function s:trim(str)
  return substitute(a:str, '\s*$', '', 'g')
endfunction

function kronos#interface#gui#parse_buffer()
  let index = -1

  for row in getline(2, '$')
    let index += 1
    if  index(s:body, row) > -1 | continue | endif

    let cells = split(row, '|')
    try
      let id = +s:trim(cells[0])
      let desc = s:trim(join(cells[1:-4], ''))
      let tags = s:trim(cells[-3])
      let active = s:trim(cells[-2])
      let due = s:trim(cells[-1])
    catch
      echo 'Error while parsing buffer.'
      return
    endtry

    let tasks = kronos#interface#common#list(g:kronos_database)

    if len(tasks) == len(s:body)
      let update = {
        \'id': id,
        \'desc': desc,
        \'tags': split(tags, ' '),
      \}

      call kronos#task#update(
        \g:kronos_database,
        \id,
        \kronos#database#merge_data(tasks[index], update),
      \)

      call kronos#interface#gui#list()
    else
      echom 'add ' . id
    endif
  endfor
endfunction

" ------------------------------------------------------------------- # Render #

function! s:render(tasks)
  let max_widths = s:get_max_widths(a:tasks, s:config.list.columns)
  let header = [s:render_row(s:config.labels, max_widths)]
  let s:body = map(copy(a:tasks), 's:render_row(v:val, max_widths)')

  return header + s:body
endfunction

function! s:render_row(row, max_widths)
  return join(map(
    \copy(s:config.list.columns),
    \'s:render_cell(a:row[v:val], a:max_widths[v:key])',
  \), '')
endfunction

function! s:render_cell(cell, max_width)
  let cell_width = strwidth(a:cell[:a:max_width])
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
  let tasks = kronos#task#read_all(g:kronos_database)
  let index = line('.') - 2
  if  index == -1 | throw 'task not found' | endif

  return +get(tasks, index).id
endfunction
