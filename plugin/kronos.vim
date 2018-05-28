let g:kronos_tasks = get(g:, 'kronos_tasks', [])
let g:kronos_database = get(
      \ g:, 'kronos_database',
      \ resolve(expand('<sfile>:h') . '/../database/tasks.vim')
      \)

