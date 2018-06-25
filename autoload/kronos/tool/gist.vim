" --------------------------------------------------------------------- # Init #

function! kronos#tool#gist#Init()
  if ! g:kronos_enable_gist | return | endif
  if filereadable(g:kronos_gist_conf) | return | endif

  let gtoken = inputsecret(
    \'Gist sync has not been configured yet. ' .
    \'Enter your GitHub token (:h kronos-gist)' .
    \"\n> "
  \)

  if gtoken =~? '^ *$' | return | endif

  try
    let gid = kronos#tool#gist#Create(gtoken)
  catch
    return kronos#tool#log#Error('Error while creating Gist.')
  endtry

  try
    call writefile([gtoken, gid], g:kronos_gist_conf, 's')
  catch
    return kronos#tool#log#Error('Error while saving Gist config.')
  endtry

  redraw
  call kronos#tool#log#Info('Gist sync configured.')
endfunction

" ------------------------------------------------------------------- # Create #

function! kronos#tool#gist#Create(token)
  let url = 'https://api.github.com/gists'
  let verb = 'POST'
  let auth = printf('Authorization: token %s', a:token)
  let body = json_encode({
    \'description': 'Kronos database',
    \'files': {'kronos.db': {'content': '{}'}}
  \})
  
  let cmd = join([
    \'curl', shellescape(url),
    \'-X'  , shellescape(verb),
    \'-H'  , shellescape(auth),
    \'-d'  , shellescape(body),
    \'-s'
  \], ' ')

  let res = systemlist(cmd)
  return matchlist(res, '"id": "\(.*\)",$')[1]
endfunction

" --------------------------------------------------------------------- # Sync #

function! kronos#tool#gist#Sync(data)
endfunction

