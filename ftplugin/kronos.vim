setlocal buftype=nofile
setlocal cursorline
setlocal nomodifiable
setlocal nowrap
setlocal startofline

nnoremap <silent> <buffer> a :call kronos#ui#gui#Add(g:kronos_database, localtime())<CR>
nnoremap <silent> <buffer> D :call kronos#ui#gui#Delete(g:kronos_database)<CR>

