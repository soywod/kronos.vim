setlocal buftype=nofile
setlocal cursorline
setlocal nomodifiable
setlocal nowrap
setlocal startofline

nnoremap <silent> <buffer> q     :bdelete                          <cr>
nnoremap <silent> <buffer> <esc> :bdelete                          <cr>
nnoremap <silent> <buffer> a     :call kronos#gui#Add()            <cr>
nnoremap <silent> <buffer> D     :call kronos#gui#Done()           <cr>
nnoremap <silent> <buffer> i     :call kronos#gui#Info()           <cr>
nnoremap <silent> <buffer> r     :call kronos#gui#List()           <cr>
nnoremap <silent> <buffer> S     :call kronos#gui#Stop()           <cr>
nnoremap <silent> <buffer> s     :call kronos#gui#Start()          <cr>
nnoremap <silent> <buffer> <bs>  :call kronos#gui#Delete()         <cr>
nnoremap <silent> <buffer> <del> :call kronos#gui#Delete()         <cr>
nnoremap <silent> <buffer> t     :call kronos#gui#Toggle()         <cr>
nnoremap <silent> <buffer> <cr>  :call kronos#gui#Toggle()         <cr>
nnoremap <silent> <buffer> u     :call kronos#gui#Update()         <cr>
nnoremap <silent> <buffer> U     :call kronos#gui#Undone()         <cr>
nnoremap <silent> <buffer> H     :call kronos#gui#ToggleHideDone() <cr>

