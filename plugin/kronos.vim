let s:database = resolve(expand('<sfile>:h:h') . '/.database')

" ------------------------------------------------------------------- # Config #

let g:kronos_context   = get(g:, 'kronos_context'  , [])
let g:kronos_database  = get(g:, 'kronos_database' , s:database)
let g:kronos_hide_done = get(g:, 'kronos_hide_done', 1)

let g:kronos_sync      = get(g:, 'kronos_sync'     , 0)
let g:kronos_sync_host = get(g:, 'kronos_sync_host', 'localhost:5000')

" ----------------------------------------------------------------- # Commands #

command! K      call kronos#ui#list()
command! Kronos call kronos#ui#list()

if g:kronos_sync
  augroup kronos
    autocmd VimEnter * call kronos#sync#init()
  augroup END
endif
