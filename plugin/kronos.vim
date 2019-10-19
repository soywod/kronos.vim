if !has('python3') | throw 'python3 is missing' | endif

let s:database = resolve(expand('<sfile>:h:h') . '/.database')

let g:kronos_database   = get(g:, 'kronos_database' , s:database)
let g:kronos_context    = get(g:, 'kronos_context'  , [])
let g:kronos_hide_done  = get(g:, 'kronos_hide_done', 1)
let g:kronos_backend    = get(g:, 'kronos_backend', 'file')

augroup kronos
  autocmd!
  autocmd VimEnter * call kronos#database#open()
  autocmd VimLeave * call kronos#database#close()
augroup end

command! Kronos call kronos#ui#list()
