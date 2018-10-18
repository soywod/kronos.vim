" --------------------------------------------------------------------- # Read #

function! kronos#database#read(database)
  try
    if ! filereadable(a:database)
      return {
        \'tasks': [],
        \'hide_done': 1,
        \'enable_sync': 0,
        \'sync_host': 'localhost:5000',
        \'sync_user_id': '',
        \'sync_device_id': '',
        \'sync_version': 0,
      \}
    endif

    let data = readfile(a:database)

    return {
      \'tasks': map(data[6:], 'eval(v:val)'),
      \'hide_done': !! data[0],
      \'enable_sync': !! data[1],
      \'sync_host': data[2],
      \'sync_user_id': data[3],
      \'sync_device_id': data[4],
      \'sync_version': +data[5],
    \}
  catch
    throw 'read database failed'
  endtry
endfunction

" -------------------------------------------------------------------- # Write #

function! kronos#database#write(database, data_part)
  try
    let data_old = kronos#database#read(a:database)
    let data_new = kronos#database#merge_data(data_old, a:data_part)

    return writefile(kronos#database#to_list(data_new), a:database, 's')
  catch
    throw 'write database failed'
  endtry
endfunction

" -------------------------------------------------------------------- # Utils #

function! kronos#database#merge_data(old, new)
  return map(copy(a:old), 's:set_value(a:old, a:new, v:key)')
endfunction

function! s:set_value(old, new, key)
  let new_has_key = has_key(a:new, a:key)
  let value = new_has_key ? a:new[a:key] : a:old[a:key]

  if a:key != 'tasks' | return value | endif
  if ! new_has_key    | return value | endif

  let tasks_done   = filter(copy(a:new.tasks), 'v:val.done')
  let tasks_undone = filter(copy(a:new.tasks), '! v:val.done')
  return tasks_undone + tasks_done
endfunction

function! kronos#database#to_list(data)
  let tasks  = map(copy(a:data.tasks), 'string(v:val)')
  let config = [
    \a:data.hide_done,
    \a:data.enable_sync,
    \a:data.sync_host,
    \a:data.sync_user_id,
    \a:data.sync_device_id,
    \a:data.sync_version,
  \]

  return config + tasks
endfunction
