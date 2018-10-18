" ------------------------------------------------------------------- # Config #

let g:kronos_sync      = get(g:, 'kronos_sync'     , 0)
let g:kronos_sync_host = get(g:, 'kronos_sync_host', 'localhost:5000')
let g:kronos_context   = get(g:, 'kronos_context'  , [])
let g:kronos_hide_done = get(g:, 'kronos_hide_done', 1)
let g:kronos_database  = get(
  \g:, 'kronos_database',
  \resolve(expand('<sfile>:h:h') . '/.database'),
\)

" ----------------------------------------------------------------- # Commands #

command! -nargs=* K      call kronos#entry_point(<q-args>)
command! -nargs=* Kronos call kronos#entry_point(<q-args>)

if g:kronos_sync
  augroup kronos
    autocmd VimEnter * call kronos#sync#common#init()
  augroup END
endif
