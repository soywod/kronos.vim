let s:socket = 0

" --------------------------------------------------------------------- # Init #

function! kronos#sync#neovim#init()
  let options = {
    \'on_data': function('s:on_data'),
  \}

  let s:socket = sockconnect('tcp', g:kronos_sync_host, options)
  if  s:socket == 0 | throw 0 | endif
endfunction

" ------------------------------------------------------------------ # On data #

function! s:on_data(id, raw_data, event)
  for raw_data in a:raw_data[:-2]
    call kronos#sync#common#on_data(raw_data)
  endfor
endfunction

" --------------------------------------------------------------------- # Send #

function! kronos#sync#neovim#send(data)
  if s:socket == 0 | return | endif
  return chansend(s:socket, json_encode(a:data))
endfunction
