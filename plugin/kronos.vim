"--------------------------------------------------------------# Configuration #

let g:kronos_database = get(
  \g:, 'kronos_database',
  \resolve(expand('<sfile>:h:h') . '/kronos.db')
\)

"--------------------------------------------------------------------# Command #

command! -nargs=* Kronos call kronos#EntryPoint(<q-args>)
command! -nargs=* K      call kronos#EntryPoint(<q-args>)

