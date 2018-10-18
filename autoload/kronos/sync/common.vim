let s:version   = 0
let s:user_id   = ''
let s:device_id = ''
let s:editor = has('nvim') ? 'neovim' : 'vim8'

" --------------------------------------------------------------------- # Init #

function! kronos#sync#common#init()
  try
    execute 'call kronos#sync#' . s:editor . '#init()'
  catch 'channel'
    return kronos#utils#log#error('sync: missing option +channel')
  catch 'job'
    return kronos#utils#log#error('sync: missing option +job')
  catch 'version'
    return kronos#utils#log#error('sync: missing vim8+')
  catch
    return kronos#utils#log#error('sync: init failed')
  endtry

  let data = kronos#database#read(g:kronos_database)
  let s:user_id = data.sync_user_id
  let s:device_id = data.sync_device_id
  let s:version = data.sync_version

  if empty(s:user_id)
    echo 'Kronos sync is not configured. Do you have a token? (y/N) '
    let user_has_token = (tolower(nr2char(getchar())) == 'y')

    if user_has_token
      let s:user_id = inputsecret(
        \'Enter your Kronos sync token:' .
        \"\n> "
      \)

      call kronos#database#write(g:kronos_database, {'sync_user_id': s:user_id})
    endif
  endif

  redraw
  call kronos#sync#common#send({'type': 'login'})
endfunction

" ------------------------------------------------------------------ # On data #

function! kronos#sync#common#on_data(data_raw)
  if empty(a:data_raw) | return | endif
  let data = json_decode(a:data_raw)

  if ! data.success
    return kronos#utils#log#error('Kronos sync: ' . data.error)
  endif

  if data.type == 'login'
    let s:user_id = data.user_id
    let s:device_id = data.device_id

    if data.version > s:version
      let s:version = data.version
      call kronos#sync#common#send({'type': 'read-all'})

    elseif data.version < s:version
      let tasks = kronos#database#read(g:kronos_database).tasks
      call kronos#sync#common#send({
        \'type': 'write-all',
        \'tasks': tasks,
        \'version': s:version,
      \})
    endif

    call kronos#utils#log#info('Kronos sync: login succeed')

  elseif data.type == 'read-all'
    call kronos#database#write(g:kronos_database, {'tasks': data.tasks})

  else
    let s:version = data.version

    try
      if data.type == 'create'
        call kronos#task#create(g:kronos_database, data.task)
      elseif data.type == 'update'
        call kronos#task#update(g:kronos_database, data.task.id, data.task)
      elseif data.type == 'delete'
        call kronos#task#delete(g:kronos_database, data.task_id)
      endif
    catch
    endtry

    if &filetype == 'klist' | call kronos#interface#gui#list() | endif
  endif

  call kronos#database#write(g:kronos_database, {
    \'sync_user_id': s:user_id,
    \'sync_device_id': s:device_id,
    \'sync_version': s:version,
  \})
endfunction

" --------------------------------------------------------------------- # Send #

function! kronos#sync#common#send(data)
  let data = copy(a:data)
  let data.user_id = s:user_id
  let data.device_id = s:device_id
  let data.version = s:version

  execute 'call kronos#sync#' . s:editor . '#send(data)'
endfunction

" ------------------------------------------------------------- # Bump version #

function! kronos#sync#common#bump_version()
  let s:version = localtime() * 1000
  call kronos#database#write(g:kronos_database, {'sync_version': s:version})
endfunction
