setlocal buftype=nofile
setlocal cursorline
setlocal nomodifiable
setlocal nowrap
setlocal startofline

nnoremap <silent> <buffer> a :call kronos#ui#gui#Add(g:kronos_database, localtime())<CR>

