let s:rootdir = expand('<sfile>:h:h')

" ------------------------------------------------------------ # Configuration #

let g:kronos_hide_done = get(g:, 'kronos_hide_done', 1)

let g:kronos_enable_gist = get(g:, 'kronos_enable_gist', 0)
let g:kronos_gist_conf   = resolve(s:rootdir . '/gist.conf')

let g:kronos_database = get(
  \g:, 'kronos_database',
  \resolve(s:rootdir . '/kronos.db'),
\)

" ------------------------------------------------------------------ # Command #

command! -nargs=* Kronos call kronos#EntryPoint(<q-args>)
command! -nargs=* K      call kronos#EntryPoint(<q-args>)

