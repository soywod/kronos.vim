let s:assign = function('kronos#utils#assign')

" --------------------------------------------------------------------- # Open #

function! kronos#database#open()
  let database = kronos#database#read()
  let g:kronos_context = database.context
  let g:kronos_hide_done = database.hide_done
endfunction

" --------------------------------------------------------------------- # Read #

function! kronos#database#read()
  try
    let file_exists = filereadable(g:kronos_database)
    return file_exists ? s:read_from_file() : s:read_from_scratch()
  catch
    throw 'read database failed'
  endtry
endfunction

function! s:read_from_file()
  let data = readfile(g:kronos_database)

  return {
    \'tasks': map(data[2:], 'eval(v:val)'),
    \'context': eval(data[0]),
    \'hide_done': !!data[1],
  \}
endfunction

function! s:read_from_scratch()
  return {
    \'tasks': [],
    \'context': [],
    \'hide_done': 1,
  \}
endfunction

" -------------------------------------------------------------------- # Write #

function! kronos#database#write(data)
  try
    let data = s:assign(kronos#database#read(), a:data)
    return s:write_to_file(data)
  catch
    throw 'write database failed'
  endtry
endfunction

function! s:write_to_file(data)
  let tasks  = map(copy(a:data.tasks), 'string(v:val)')
  let config = [string(a:data.context), a:data.hide_done]

  return writefile(config + tasks, g:kronos_database, 's')
endfunction

" -------------------------------------------------------------------- # Close #

function! kronos#database#close()
  call kronos#database#write({
    \'context': g:kronos_context,
    \'hide_done': g:kronos_hide_done
  \})
endfunction
