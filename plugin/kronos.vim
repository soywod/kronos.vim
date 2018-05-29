let g:kronos_tasks = get(g:, 'kronos_tasks', [])
let g:kronos_database = get(
  \ g:, 'kronos_database',
  \ resolve(expand('<sfile>:h') . '/../database/tasks.vim')
\)

command! -nargs=* KronosAdd
  \ call kronos#cli#Add(g:kronos_database, localtime(), <q-args>)

command! -nargs=1 KronosInfo
  \ call kronos#cli#Info(g:kronos_database, <args>)

" command! -nargs=1 KronosList
"   \ call kronos#cli#List(g:kronos_database, <args>)

" command! -nargs=* KronosUpdate
"   \ call kronos#cli#Update(g:kronos_database, <q-args>)

" command! -nargs=1 KronosDelete
"   \ call kronos#cli#Delete(g:kronos_database, <args>)

" command! -nargs=1 KronosStart
"   \ call kronos#cli#Start(g:kronos_database, <args>)

" command! -nargs=1 KronosStop
"   \ call kronos#cli#Stop(g:kronos_database, <args>)

