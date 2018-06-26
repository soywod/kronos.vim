let s:baseurl = 'https://api.github.com/gists'

" --------------------------------------------------------------------- # Init #

function! kronos#integration#gist#Init()
  if filereadable(g:kronos_gist_conf)
    let [s:gid, s:gtoken] = readfile(g:kronos_gist_conf)
    return kronos#integration#gist#Read()
  endif

  let s:gtoken = inputsecret(
    \'Gist sync has not been configured yet. ' .
    \'Enter your GitHub token (:h kronos-gist-sync)' .
    \"\n> "
  \)

  if s:gtoken =~? '^ *$'
    return kronos#tool#log#Error('Operation canceled.')
  endif

  try
    redraw | call kronos#tool#log#Info('Processing ...')
    let s:gid = kronos#integration#gist#Create()
  catch
    return kronos#tool#log#Error('Error while creating Gist.')
  endtry

  try
    call writefile([s:gid, s:gtoken], g:kronos_gist_conf, 's')
  catch
    return kronos#tool#log#Error('Error while saving Gist config.')
  endtry

  let tasks = kronos#core#database#Read(g:kronos_database)
  call kronos#core#database#Write(g:kronos_database, tasks)
  
  redraw | call kronos#tool#log#Info('Gist sync configured.')
endfunction

" ------------------------------------------------------------------- # Create #

function! kronos#integration#gist#Create()
  let header  = printf('Authorization: token %s', s:gtoken)
  let httpv   = 'POST'
  let body    = json_encode({
    \'description': 'Kronos database',
    \'files': {'kronos.db': {'content': '{}'}},
  \})
  
  let cmd = join([
    \'curl', shellescape(s:baseurl),
    \'-H'  , shellescape(header),
    \'-X'  , shellescape(httpv),
    \'-d'  , shellescape(body),
    \'-s',
  \], ' ')

  let res = systemlist(cmd)
  return matchlist(res, '"id": "\(.*\)",\?$')[1]
endfunction

" --------------------------------------------------------------------- # Read #

function! kronos#integration#gist#Read()
  let header = printf('Authorization: token %s', s:gtoken)
  let curl   = join([
    \'curl', shellescape(s:baseurl . '/' . s:gid),
    \'-H'  , shellescape(header),
    \'-s',
  \], ' ')

  call job_start(
    \['/bin/sh', '-c', curl],
    \{'out_cb': 'ReadCallback', 'mode': 'nl'},
  \)
endfunction

function! ReadCallback(_, data)
  let matches = matchlist(a:data, '"content": "\({.*}\)",\?$')
  if  empty(matches) | return | endif

  if matches[1] != '{}'
    let data = split(matches[1], '\\n')
    call writefile(data, g:kronos_database, 's')
  endif
endfunction

" -------------------------------------------------------------------- # Write #

function! kronos#integration#gist#Write(data)
  let httpv  = 'PATCH'
  let header = printf('Authorization: token %s', s:gtoken)
  let body   = json_encode({
    \'files': {'kronos.db': {'content': a:data}},
  \})
  
  let curl = join([
    \'curl', shellescape(s:baseurl . '/' . s:gid),
    \'-H'  , shellescape(header),
    \'-X'  , shellescape(httpv),
    \'-d'  , shellescape(body),
    \'-s',
  \], ' ')

  call job_start(['/bin/sh', '-c', curl])
endfunction

