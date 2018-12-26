setlocal buftype=acwrite
setlocal cursorline
setlocal nowrap
setlocal startofline

augroup klist
  autocmd! * <buffer>
  autocmd  BufWriteCmd <buffer> call kronos#ui#parse_buffer()
augroup end

" ------------------------------------------------------------ # Main commands #

nnoremap <nowait><buffer><silent> <Space> :call kronos#ui#list()            <CR>
nnoremap <nowait><buffer><silent> <CR>    :call kronos#ui#toggle()          <CR>
nnoremap <nowait><buffer><silent> K       :call kronos#ui#info()            <CR>
nnoremap <nowait><buffer>         gc      :call kronos#ui#context()         <CR>
nnoremap <nowait><buffer><silent> gh      :call kronos#ui#toggle_hide_done()<CR>
nnoremap <nowait><buffer><silent> gw      :call kronos#ui#worktime()        <CR>

" ---------------------------------------------------------- # Cell management #

nnoremap <silent> <buffer> <Tab> :call kronos#ui#select_next_cell()<CR>
nnoremap <silent> <buffer> <C-n> :call kronos#ui#select_next_cell()<CR>
vnoremap <silent> <buffer> <Tab> :call kronos#ui#select_next_cell()<CR>
vnoremap <silent> <buffer> <C-n> :call kronos#ui#select_next_cell()<CR>

nnoremap <silent> <buffer> <S-Tab> :call kronos#ui#select_prev_cell()<CR>
nnoremap <silent> <buffer> <C-p> :call kronos#ui#select_prev_cell()  <CR>
vnoremap <silent> <buffer> <S-Tab> :call kronos#ui#select_prev_cell()<CR>
vnoremap <silent> <buffer> <C-p> :call kronos#ui#select_prev_cell()  <CR>

nnoremap <silent> <buffer> dic :call kronos#ui#delete_in_cell()<CR>
nnoremap <silent> <buffer> cic :call kronos#ui#change_in_cell()<CR>
nnoremap <silent> <buffer> vic :call kronos#ui#visual_in_cell()<CR>
