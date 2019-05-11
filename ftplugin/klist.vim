setlocal buftype=acwrite
setlocal cursorline
setlocal nowrap
setlocal startofline

augroup klist
  autocmd! * <buffer>
  autocmd  BufWriteCmd <buffer> call kronos#ui#parse_buffer()
augroup end

" ------------------------------------------------------------ # Main commands #

nnoremap <buffer> <nowait> <silent> <space> :call kronos#ui#list()     <cr>
nnoremap <buffer> <nowait> <silent> <cr>    :call kronos#ui#toggle()   <cr>
nnoremap <buffer> <nowait> <silent> K       :call kronos#ui#info()     <cr>
nnoremap <buffer> <nowait>          gc      :call kronos#ui#context()  <cr>
nnoremap <buffer> <nowait> <silent> gh      :call kronos#ui#hide_done()<cr>
nnoremap <buffer> <nowait> <silent> gw      :call kronos#ui#worktime() <cr>

" ---------------------------------------------------------- # Cell management #

nnoremap <buffer> <silent> <tab> :call kronos#ui#select_next_cell()<cr>
nnoremap <buffer> <silent> <c-n> :call kronos#ui#select_next_cell()<cr>
vnoremap <buffer> <silent> <tab> :call kronos#ui#select_next_cell()<cr>
vnoremap <buffer> <silent> <c-n> :call kronos#ui#select_next_cell()<cr>

nnoremap <buffer> <silent> <s-tab> :call kronos#ui#select_prev_cell()<cr>
nnoremap <buffer> <silent> <c-p>   :call kronos#ui#select_prev_cell()<cr>
vnoremap <buffer> <silent> <s-tab> :call kronos#ui#select_prev_cell()<cr>
vnoremap <buffer> <silent> <c-p>   :call kronos#ui#select_prev_cell()<cr>

nnoremap <buffer> <silent> dic :call kronos#ui#delete_in_cell()<cr>
nnoremap <buffer> <silent> cic :call kronos#ui#change_in_cell()<cr>
nnoremap <buffer> <silent> vic :call kronos#ui#visual_in_cell()<cr>
