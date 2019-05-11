let s:database = resolve(expand('<sfile>:h:h') . '/.database')

let g:kronos_database  = get(g:, 'kronos_database' , s:database)
let g:kronos_context   = get(g:, 'kronos_context'  , [])
let g:kronos_hide_done = get(g:, 'kronos_hide_done', 1)

function! s:read_config()
  let database = kronos#database#read()
  let g:kronos_context = database.context
  let g:kronos_hide_done = database.hide_done
endfunction

function! s:write_config()
  call kronos#database#write({
    \'context': g:kronos_context,
    \'hide_done': g:kronos_hide_done
  \})
endfunction

augroup kronos
  autocmd VimEnter * call s:read_config()
  autocmd VimLeave * call s:write_config()
augroup end

command! Kronos call kronos#ui#list()
