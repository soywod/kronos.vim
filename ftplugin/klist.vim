setlocal buftype=acwrite
setlocal cursorline
setlocal nowrap
setlocal startofline

augroup klist
  autocmd! * <buffer>
  autocmd  BufWriteCmd <buffer> call kronos#ui#parse_buffer()
augroup end

" ----------------------------------------------------------------- # Commands #

nnoremap <silent> <buffer> <cr> :call kronos#ui#toggle() <cr>
nnoremap <silent> <buffer> K    :call kronos#ui#info()   <cr>
nnoremap          <buffer> gc   :call kronos#ui#context()<cr>

" ---------------------------------------------------------------- # Next cell #

nnoremap <silent> <buffer> <tab> :call kronos#ui#select_next_cell()<cr>
vnoremap <silent> <buffer> <tab> :call kronos#ui#select_next_cell()<cr>

nnoremap <silent> <buffer> <c-n> :call kronos#ui#select_next_cell()<cr>
vnoremap <silent> <buffer> <c-n> :call kronos#ui#select_next_cell()<cr>

" ---------------------------------------------------------------- # Prev cell #

nnoremap <silent> <buffer> <s-tab> :call kronos#ui#select_prev_cell()<cr>
vnoremap <silent> <buffer> <s-tab> :call kronos#ui#select_prev_cell()<cr>

nnoremap <silent> <buffer> <c-p> :call kronos#ui#select_prev_cell()<cr>
vnoremap <silent> <buffer> <c-p> :call kronos#ui#select_prev_cell()<cr>

" ---------------------------------------------------------- # Cell management #

nnoremap <silent> <buffer> dic :call kronos#ui#delete_in_cell()<cr>
nnoremap <silent> <buffer> cic :call kronos#ui#change_in_cell()<cr>
nnoremap <silent> <buffer> vic :call kronos#ui#visual_in_cell()<cr>
