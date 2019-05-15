setlocal bufhidden=wipe
setlocal buftype=nofile
setlocal cursorline
setlocal nomodifiable
setlocal nowrap
setlocal startofline

nnoremap <buffer> <silent> q     :bwipeout<cr>
nnoremap <buffer> <silent> <cr>  :bwipeout<cr>
nnoremap <buffer> <silent> <esc> :bwipeout<cr>
