setlocal buftype=nofile
setlocal cursorline
" setlocal nomodifiable
setlocal nowrap
setlocal startofline

augroup klist
  autocmd! * <buffer>
  autocmd InsertLeave,TextChanged <buffer> call kronos#interface#gui#parse_buffer()
augroup end

" nnoremap <silent> <buffer> q     :bdelete                                      <cr>
" nnoremap <silent> <buffer> <esc> :bdelete                                      <cr>
" nnoremap <silent> <buffer> a     :call kronos#interface#gui#add()              <cr>
" nnoremap <silent> <buffer> D     :call kronos#interface#gui#done()             <cr>
" nnoremap <silent> <buffer> i     :call kronos#interface#gui#info()             <cr>
" nnoremap <silent> <buffer> r     :call kronos#interface#gui#list()             <cr>
" nnoremap <silent> <buffer> S     :call kronos#interface#gui#stop()             <cr>
" nnoremap <silent> <buffer> s     :call kronos#interface#gui#start()            <cr>
" nnoremap <silent> <buffer> <bs>  :call kronos#interface#gui#delete()           <cr>
" nnoremap <silent> <buffer> <del> :call kronos#interface#gui#delete()           <cr>
" nnoremap <silent> <buffer> t     :call kronos#interface#gui#toggle()           <cr>
" nnoremap <silent> <buffer> <cr>  :call kronos#interface#gui#toggle()           <cr>
" nnoremap <silent> <buffer> u     :call kronos#interface#gui#update()           <cr>
" nnoremap <silent> <buffer> U     :call kronos#interface#gui#undone()           <cr>
" nnoremap <silent> <buffer> C     :call kronos#interface#gui#context()          <cr>
" nnoremap <silent> <buffer> H     :call kronos#interface#gui#toggle_hide_done() <cr>
