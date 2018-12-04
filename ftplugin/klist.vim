setlocal buftype=acwrite
setlocal cursorline
" setlocal nomodifiable
setlocal nowrap
setlocal startofline

augroup klist
  autocmd! * <buffer>
  autocmd  BufWriteCmd <buffer> call kronos#interface#gui#parse_buffer()
augroup end

" ----------------------------------------------------------------- # Commands #

nnoremap <silent> <buffer> <cr> :call kronos#interface#gui#toggle()<cr>
nnoremap <silent> <buffer> K    :call kronos#interface#gui#info()<cr>

" ---------------------------------------------------------------- # Next cell #

nnoremap <silent> <buffer> <tab> :call kronos#interface#gui#select_next_cell()<cr>
vnoremap <silent> <buffer> <tab> :call kronos#interface#gui#select_next_cell()<cr>

nnoremap <silent> <buffer> <c-n> :call kronos#interface#gui#select_next_cell()<cr>
vnoremap <silent> <buffer> <c-n> :call kronos#interface#gui#select_next_cell()<cr>

" ---------------------------------------------------------------- # Prev cell #

nnoremap <silent> <buffer> <s-tab> :call kronos#interface#gui#select_prev_cell()<cr>
vnoremap <silent> <buffer> <s-tab> :call kronos#interface#gui#select_prev_cell()<cr>

nnoremap <silent> <buffer> <c-p> :call kronos#interface#gui#select_prev_cell()<cr>
vnoremap <silent> <buffer> <c-p> :call kronos#interface#gui#select_prev_cell()<cr>

" -------------------------------------------------------------- # Cell update #

nnoremap <silent> <buffer> dic :call kronos#interface#gui#delete_in_cell()<cr>
nnoremap <silent> <buffer> cic :call kronos#interface#gui#change_in_cell()<cr>
nnoremap <silent> <buffer> vic :call kronos#interface#gui#visual_in_cell()<cr>

let &modified = 0
