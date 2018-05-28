let s:MINS_IN_HOUR = 60
let s:HOURS_IN_DAY = 24
let s:DAYS_IN_MONTH = 32
let s:DAYS_IN_YEAR =  366
let s:SECS_IN_MIN = 60
let s:SECS_IN_HOUR = s:SECS_IN_MIN * s:MINS_IN_HOUR
let s:SECS_IN_DAY = s:SECS_IN_HOUR * s:HOURS_IN_DAY
let s:SECS_IN_MONTH = s:SECS_IN_DAY * s:DAYS_IN_MONTH
let s:SECS_IN_YEAR = s:SECS_IN_DAY * s:DAYS_IN_YEAR

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

function! kronos#cli#ParseDue(dateref, duestr)
  let l:matches = matchlist(
    \ a:duestr,
    \ '^:\(\d\{0,2}\)\(\d\{0,2}\)\(\d\{2}\)\?:\?\(\d\{0,2}\)\(\d\{0,2}\)$'
  \)

  let l:daymatch = l:matches[1]
  let l:monthmatch = l:matches[2]
  let l:yearmatch = l:matches[3]
  let l:hourmatch = l:matches[4]
  let l:minmatch = l:matches[5]

  return s:ApproximateDateFromDue(
        \ a:dateref,
        \ v:null,
        \ l:daymatch,
        \ l:monthmatch,
        \ l:yearmatch,
        \ l:hourmatch,
        \ l:minmatch,
        \)
endfunction

function! s:ApproximateDateFromDue(dateref, dateapprox, day, month, year, hour, min)
  let l:dayref = +strftime('%d', a:dateref)
  let l:monthref = +strftime('%m', a:dateref)
  let l:yearref = +strftime('%y', a:dateref)
  let l:hourref = +strftime('%H', a:dateref)
  let l:minref = +strftime('%M', a:dateref)

  let l:daymatch = a:day == '' ? l:dayref : +a:day
  let l:monthmatch = a:month == '' ? l:monthref : +a:month
  let l:yearmatch = a:year == '' ? l:yearref : +a:year
  let l:hourmatch = a:hour == '' ? l:hourref : +a:hour
  let l:minmatch = a:min == '' ? 0 : +a:min

  let l:daydiff = (l:daymatch - l:dayref) * s:SECS_IN_DAY
  let l:monthdiff = (l:monthmatch - l:monthref) * s:SECS_IN_MONTH
  let l:yeardiff = (l:yearmatch - l:yearref) * s:SECS_IN_YEAR
  let l:hourdiff = (l:hourmatch - l:hourref) * s:SECS_IN_HOUR
  let l:mindiff = (l:minmatch - l:minref) * s:SECS_IN_MIN
  let l:diff = l:daydiff + l:monthdiff + l:yeardiff + l:mindiff + l:hourdiff
  if  l:diff == 0 | return a:dateref | endif

  if l:diff < 0
    if l:yeardiff < 0 | throw 'invalid-date'
    elseif l:monthdiff < 0 | let l:diff += s:SECS_IN_YEAR
    elseif l:daydiff < 0 | let l:diff += s:SECS_IN_MONTH
    elseif l:hourdiff < 0 | let l:diff += s:SECS_IN_DAY
    elseif l:mindiff < 0 | let l:diff += s:SECS_IN_DAY
    endif
  endif

  let l:dateapprox = a:dateref + l:diff

  if a:day != ''
    let l:dateapprox += (a:day - strftime('%d', l:dateapprox)) * s:SECS_IN_DAY
  endif

  let l:dateapprox += (a:hour - strftime('%H', l:dateapprox)) * s:SECS_IN_HOUR
  if  l:dateapprox == a:dateapprox | return l:dateapprox | endif

  return s:ApproximateDateFromDue(
        \ a:dateref,
        \ l:dateapprox,
        \ a:day,
        \ strftime('%m', l:dateapprox),
        \ strftime('%y', l:dateapprox),
        \ a:hour,
        \ strftime('%M', l:dateapprox),
        \)
endfunction

