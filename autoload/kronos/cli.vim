function! kronos#cli#Add(database, dateref, args)
  let l:args = split(a:args, ' ')
  let l:desc = []
  let l:due = 0
  let l:tags = []

  for l:arg in l:args
    if l:arg =~ '^+\w'
      call add(l:tags, l:arg[1:])
    elseif l:arg =~ '^:\w*'
      let l:due = kronos#datetime#ParseDue(a:dateref, l:arg)
    else
      call add(l:desc, l:arg)
    endif
  endfor

  let l:id = kronos#task#Create(a:database, {
    \ 'desc': join(l:desc, ' '),
    \ 'tags': l:tags,
    \ 'due': l:due,
  \})

  echo 'Task [' . l:id . '] added !'
endfunction

function! kronos#cli#Info(database, id)
  try
    let l:task = kronos#task#Read(a:database, a:id)

    for [l:key, l:value] in items(l:task)
      echo l:key . ': ' . string(l:value)
    endfor
  catch 'task-not-found'
    call s:LogError('Task [' . a:id . '] not found !')
  endtry
endfunction

function! s:LogError(msg)
  echohl ErrorMsg
  echo a:msg
  echohl None
endfunction

