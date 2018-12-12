let s:socket = 0

" --------------------------------------------------------------------- # Init #

function! kronos#sync#neovim#init()
  let options = {
    \'on_data': function('s:handle_data'),
  \}

  let s:socket = sockconnect('tcp', g:kronos_sync_host, options)
  if  s:socket == 0 | throw 0 | endif
endfunction

" -------------------------------------------------------------- # Handle data #

function! s:handle_data(id, raw_data_list, event)
  let raw_data_list = a:raw_data_list[:-2]

  if empty(raw_data_list)
    return kronos#sync#handle_close()
  endif

  for raw_data in raw_data_list
    call kronos#sync#handle_data(raw_data)
  endfor
endfunction

" --------------------------------------------------------------------- # Send #

function! kronos#sync#neovim#send(data)
  if s:socket == 0 | return | endif
  return chansend(s:socket, json_encode(a:data))
endfunction
