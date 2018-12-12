" --------------------------------------------------------------------- # Read #

function! kronos#database#read()
  try
    let file_readable = filereadable(g:kronos_database)
    return file_readable ? s:read_from_file() : s:read_from_scratch()
  catch
    throw 'read database failed'
  endtry
endfunction

function! s:read_from_file()
  let data = readfile(g:kronos_database)

  return {
    \'tasks': map(data[6:], 'eval(v:val)'),
    \'hide_done': !!data[0],
    \'enable_sync': !!data[1],
    \'sync_host': data[2],
    \'sync_user_id': data[3],
    \'sync_device_id': data[4],
    \'sync_version': +data[5],
  \}
endfunction

function! s:read_from_scratch()
  return {
    \'tasks': [],
    \'hide_done': 1,
    \'enable_sync': 0,
    \'sync_host': 'localhost:5000',
    \'sync_user_id': '',
    \'sync_device_id': '',
    \'sync_version': 0,
  \}
endfunction

" -------------------------------------------------------------------- # Write #

function! kronos#database#write(data)
  try
    let data = kronos#utils#assign(kronos#database#read(), a:data)
    return s:write_to_file(data)
  catch
    throw 'write database failed'
  endtry
endfunction

function! s:write_to_file(data)
  let tasks  = map(copy(a:data.tasks), 'string(v:val)')
  let config = [
    \a:data.hide_done,
    \a:data.enable_sync,
    \a:data.sync_host,
    \a:data.sync_user_id,
    \a:data.sync_device_id,
    \a:data.sync_version,
  \]

  return writefile(config + tasks, g:kronos_database, 's')
endfunction
