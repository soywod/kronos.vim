setlocal buftype=nofile
setlocal cursorline
setlocal nomodifiable
setlocal nowrap
setlocal startofline

nnoremap <silent> <buffer> a :call kronos#ui#gui#Add()<CR>
nnoremap <silent> <buffer> i :call kronos#ui#gui#Info()<CR>
nnoremap <silent> <buffer> u :call kronos#ui#gui#Update()<CR>
nnoremap <silent> <buffer> D :call kronos#ui#gui#Delete()<CR>
nnoremap <silent> <buffer> q :bdelete<CR>

