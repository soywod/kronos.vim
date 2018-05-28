function! kronos#cli#Create(database, args)
  let l:args = split(a:args, ' ')
  let l:desc = []
  let l:due = v:null
  let l:tags = []

  for l:arg in l:args
    if l:arg =~ '^+\w'
      call add(l:tags, l:arg[1:])
    elseif l:arg =~ '^:\w*'
      let l:due = l:arg[1:]
    else
      call add(l:desc, l:arg)
    endif
  endfor

  let l:task = {
    \ 'desc': join(l:desc, ' '),
    \ 'tags': l:tags,
    \ 'due': l:due
  \}

  call kronos#task#Create(a:database, l:task)
endfunction

