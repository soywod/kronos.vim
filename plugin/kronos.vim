let g:kronos_database = get(
  \ g:, 'kronos_database',
  \ resolve(expand('<sfile>:h:h') . '/database')
\)

command! Kronos call kronos#ui#gui#Open(g:kronos_database)

command! -nargs=* KronosAdd
  \ call kronos#ui#cli#Add(g:kronos_database, localtime(), <q-args>)

command! -nargs=1 KronosInfo
  \ call kronos#ui#cli#Info(g:kronos_database, <args>)

command! KronosList
  \ call kronos#ui#cli#List(g:kronos_database)

command! -nargs=* KronosUpdate
  \ call kronos#ui#cli#Update(g:kronos_database, localtime(), <q-args>)

command! -nargs=1 KronosDelete
  \ call kronos#ui#cli#Delete(g:kronos_database, <args>)

command! -nargs=1 KronosStart
  \ call kronos#ui#cli#Start(g:kronos_database, localtime(), <args>)

command! -nargs=1 KronosStop
  \ call kronos#ui#cli#Stop(g:kronos_database, localtime(), <args>)

command! -nargs=1 KronosDone
  \ call kronos#ui#cli#Done(g:kronos_database, localtime(), <args>)

