let s:version   = 0
let s:user_id   = ''
let s:device_id = ''
let s:editor = has('nvim') ? 'neovim' : 'vim8'

" --------------------------------------------------------------------- # Init #

function! kronos#sync#init()
  try
    execute 'call kronos#sync#' . s:editor . '#init()'
  catch 'channel'
    return kronos#utils#error_log('sync: missing option +channel')
  catch 'job'
    return kronos#utils#error_log('sync: missing option +job')
  catch 'version'
    return kronos#utils#error_log('sync: missing vim8+')
  catch
    return kronos#utils#error_log('sync: init failed')
  endtry

  let data = kronos#database#read()
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

      call kronos#database#write({'sync_user_id': s:user_id})
    endif
  endif

  redraw | call kronos#sync#send({'type': 'login'})
endfunction

" -------------------------------------------------------------- # Handle data #

function! kronos#sync#handle_data(data_raw)
  if empty(a:data_raw) | return | endif
  let data = json_decode(a:data_raw)

  if !data.success
    return kronos#utils#error_log('sync: ' . data.error)
  endif

  if data.type == 'login'
    let s:user_id = data.user_id
    let s:device_id = data.device_id

    if data.version > s:version
      let s:version = data.version
      call kronos#sync#send({'type': 'read-all'})

    elseif data.version < s:version
      let tasks = kronos#database#read().tasks
      call kronos#sync#send({
        \'type': 'write-all',
        \'tasks': tasks,
        \'version': s:version,
      \})
    endif

    call kronos#utils#log('Kronos: sync: login succeed.')

  elseif data.type == 'read-all'
    let s:version = data.version
    call kronos#database#write({'tasks': data.tasks})

  elseif data.version > s:version
    let s:version = data.version

    try
      if data.type == 'create'
        call kronos#task#create(data.task)
      elseif data.type == 'update'
        call kronos#task#update(data.task.id, data.task)
      elseif data.type == 'delete'
        call kronos#task#delete(data.task_id)
      endif
    catch
    endtry

    if &filetype == 'klist' && !&modified
      call kronos#ui#list()
    endif
  endif

  call kronos#database#write({
    \'sync_user_id': s:user_id,
    \'sync_device_id': s:device_id,
    \'sync_version': s:version,
  \})
endfunction

" ------------------------------------------------------------- # Handle close #

function! kronos#sync#handle_close()
  call kronos#utils#error_log('sync: connection lost')
endfunction

" ------------------------------------------------------------- # Bump version #

function! kronos#sync#bump_version()
  let s:version = kronos#utils#date#localtime()
  return s:version
endfunction

" --------------------------------------------------------------------- # Send #

function! kronos#sync#send(data)
  if index(['create', 'update', 'delete'], a:data.type) != -1
    let sync_version = kronos#sync#bump_version()
    call kronos#database#write({'sync_version': sync_version})
  endif

  if !g:kronos_sync | return | endif

  let data = kronos#utils#assign(a:data, {
    \'user_id': s:user_id,
    \'device_id': s:device_id,
    \'version': s:version,
  \})

  execute 'call kronos#sync#' . s:editor . '#send(data)'
endfunction
