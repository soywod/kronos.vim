setlocal buftype=nofile
setlocal cursorline
setlocal nomodifiable
setlocal nowrap
setlocal startofline

nnoremap <silent> <buffer> a :call kronos#ui#gui#Add(g:kronos_database, localtime())<CR>
nnoremap <silent> <buffer> i :call kronos#ui#gui#Info(g:kronos_database, kronos#ui#gui#GetCurrentLineId())<CR>
nnoremap <silent> <buffer> D :call kronos#ui#gui#Delete(g:kronos_database, kronos#ui#gui#GetCurrentLineId())<CR>
nnoremap <silent> <buffer> q :bdelete<CR>

