let s:baseurl = 'https://api.github.com/gists'

" --------------------------------------------------------------------- # Init #

function! kronos#tool#gist#Init()
  if filereadable(g:kronos_gist_conf)
    let [s:gid, s:gtoken] = readfile(g:kronos_gist_conf)
    let data = kronos#tool#gist#Read()

    return writefile(data, g:kronos_database, 's')
  endif

  let s:gtoken = inputsecret(
    \'Gist sync has not been configured yet. ' .
    \'Enter your GitHub token (:h kronos-gist)' .
    \"\n> "
  \)

  if s:gtoken =~? '^ *$'
    return kronos#tool#log#Error('Operation canceled.')
  endif

  try
    redraw | call kronos#tool#log#Info('Processing ...')
    let s:gid = kronos#tool#gist#Create()
  catch
    return kronos#tool#log#Error('Error while creating Gist.')
  endtry

  try
    call writefile([s:gid, s:gtoken], g:kronos_gist_conf, 's')
  catch
    return kronos#tool#log#Error('Error while saving Gist config.')
  endtry

  redraw | call kronos#tool#log#Info('Gist sync configured.')
endfunction

" ------------------------------------------------------------------- # Create #

function! kronos#tool#gist#Create()
  let header = printf('Authorization: token %s', s:gtoken)
  let httpv  = 'POST'
  let body   = json_encode({
    \'description': 'Kronos database',
    \'files': {'kronos.db': {'content': '{}'}}
  \})
  
  let cmd = join([
    \'curl', shellescape(s:baseurl),
    \'-H'  , shellescape(header),
    \'-X'  , shellescape(httpv),
    \'-d'  , shellescape(body),
    \'-s'
  \], ' ')

  let res = systemlist(cmd)
  return matchlist(res, '"id": "\(.*\)",\?$')[1]
endfunction

" --------------------------------------------------------------------- # Read #

function! kronos#tool#gist#Read()
  let header = printf('Authorization: token %s', s:gtoken)
  let cmd    = join([
    \'curl', shellescape(s:baseurl . '/' . s:gid),
    \'-H'  , shellescape(header),
    \'-s'
  \], ' ')

  let res  = systemlist(cmd)
  let data = matchlist(res, '"content": "\(.*\)",\?$')[1]

  return data == '{}' ? [] : split(data, '\\n')
endfunction

" -------------------------------------------------------------------- # Write #

function! kronos#tool#gist#Write(data)
  let httpv  = 'PATCH'
  let header = printf('Authorization: token %s', s:gtoken)
  let body   = json_encode({
    \'files': {'kronos.db': {'content': a:data}}
  \})
  
  let cmd = join([
    \'curl', shellescape(s:baseurl . '/' . s:gid),
    \'-H'  , shellescape(header),
    \'-X'  , shellescape(httpv),
    \'-d'  , shellescape(body),
    \'-s'
  \], ' ')

  call system(cmd)
endfunction

