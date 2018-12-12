setlocal buftype=nofile
setlocal cursorline
setlocal nomodifiable
setlocal nowrap
setlocal startofline

" ----------------------------------------------------------------- # Commands #

nnoremap <buffer><silent> K     :bdelete <CR>
nnoremap <buffer><silent> q     :bdelete <CR>
nnoremap <buffer><silent> <CR>  :bdelete <CR>
nnoremap <buffer><silent> <Esc> :bdelete <CR>
