setlocal buftype=nofile
setlocal cursorline
setlocal nomodifiable
setlocal nowrap
setlocal startofline

nnoremap <silent> <buffer> a      :call kronos#ui#gui#Add(g:kronos_database, localtime())<CR>
nnoremap <silent> <buffer> D      :call kronos#ui#gui#Delete(g:kronos_database)<CR>
nnoremap <silent> <buffer> <esc>  :bdelete<CR>
nnoremap <silent> <buffer> q      :bdelete<CR>
nnoremap <silent> <buffer> h      :help kronos<CR>

