setlocal buftype=nofile
setlocal cursorline
setlocal nomodifiable
setlocal nowrap
setlocal startofline


nnoremap <silent> <buffer> a     :call kronos#ui#gui#Add()     <cr>
nnoremap <silent> <buffer> i     :call kronos#ui#gui#Info()    <cr>
nnoremap <silent> <buffer> u     :call kronos#ui#gui#Update()  <cr>
nnoremap <silent> <buffer> <bs>  :call kronos#ui#gui#Delete()  <cr>
nnoremap <silent> <buffer> <del> :call kronos#ui#gui#Delete()  <cr>
nnoremap <silent> <buffer> s     :call kronos#ui#gui#Start()   <cr>
nnoremap <silent> <buffer> S     :call kronos#ui#gui#Stop()    <cr>
nnoremap <silent> <buffer> <cr>  :call kronos#ui#gui#Toggle()  <cr>
nnoremap <silent> <buffer> D     :call kronos#ui#gui#Done()    <cr>
nnoremap <silent> <buffer> r     :call kronos#ui#gui#ShowList()<cr>
nnoremap <silent> <buffer> q     :bdelete                      <cr>

