setlocal buftype=acwrite
setlocal cursorline
setlocal nowrap
setlocal startofline

let mappings = [
  \['n', '<space>', 'list'          ],
  \['n', '<cr>',    'toggle'        ],
  \['n', 'K',       'info'          ],
  \['n', 'gc',      'context'       ],
  \['n', 'gh',      'hide-done'     ],
  \['n', 'gw',      'worktime'      ],
  \['n', 'gs',      'sort-asc'      ],
  \['n', 'gS',      'sort-desc'     ],
  \['n', '<c-n>',   'next-cell'     ],
  \['n', '<c-p>',   'prev-cell'     ],
  \['n', 'dic',     'delete-in-cell'],
  \['n', 'cic',     'change-in-cell'],
  \['n', 'vic',     'visual-in-cell'],
\]

nnoremap <silent> <plug>(kronos-list)       :call kronos#ui#list()      <cr>
nnoremap <silent> <plug>(kronos-toggle)     :call kronos#ui#toggle()    <cr>
nnoremap <silent> <plug>(kronos-info)       :call kronos#ui#info()      <cr>
nnoremap <silent> <plug>(kronos-context)    :call kronos#ui#context()   <cr>
nnoremap <silent> <plug>(kronos-hide-done)  :call kronos#ui#hide_done() <cr>
nnoremap <silent> <plug>(kronos-worktime)   :call kronos#ui#worktime()  <cr>
nnoremap <silent> <plug>(kronos-sort-asc)   :call kronos#ui#sort(1)     <cr>
nnoremap <silent> <plug>(kronos-sort-desc)  :call kronos#ui#sort(-1)    <cr>

nnoremap <silent> <plug>(kronos-next-cell)  :call kronos#ui#select_next_cell()<cr>
nnoremap <silent> <plug>(kronos-prev-cell)  :call kronos#ui#select_prev_cell()<cr>
vnoremap <silent> <plug>(kronos-next-cell)  :call kronos#ui#select_next_cell()<cr>
vnoremap <silent> <plug>(kronos-prev-cell)  :call kronos#ui#select_prev_cell()<cr>

nnoremap <silent> <plug>(kronos-delete-in-cell) :call kronos#ui#delete_in_cell()<cr>
nnoremap <silent> <plug>(kronos-change-in-cell) :call kronos#ui#change_in_cell()<cr>
nnoremap <silent> <plug>(kronos-visual-in-cell) :call kronos#ui#visual_in_cell()<cr>

for [mode, key, plug] in mappings
  let plug = printf('<plug>(kronos-%s)', plug)

  if !hasmapto(plug, mode)
    execute printf('%smap <nowait> <buffer> %s %s', mode, key, plug)
  endif
endfor

augroup klist
  autocmd! * <buffer>
  autocmd  BufWriteCmd <buffer> call kronos#ui#parse_buffer()
augroup end
