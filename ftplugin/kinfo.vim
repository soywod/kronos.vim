setlocal buftype=nofile
setlocal cursorline
setlocal nomodifiable
setlocal nowrap
setlocal startofline

" ----------------------------------------------------------------- # Commands #

nnoremap <silent> <buffer> K     :bdelete <cr>
nnoremap <silent> <buffer> q     :bdelete <cr>
nnoremap <silent> <buffer> <cr>  :bdelete <cr>
nnoremap <silent> <buffer> <esc> :bdelete <cr>
