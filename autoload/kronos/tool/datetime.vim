"------------------------------------------------------------------# Constants #

let s:MINS_IN_HOUR = 60
let s:HOURS_IN_DAY = 24
let s:DAYS_IN_MONTH = 32
let s:DAYS_IN_YEAR =  366

let s:SECS_IN_MIN = 60
let s:SECS_IN_HOUR = s:SECS_IN_MIN * s:MINS_IN_HOUR
let s:SECS_IN_DAY = s:SECS_IN_HOUR * s:HOURS_IN_DAY
let s:SECS_IN_MONTH = s:SECS_IN_DAY * s:DAYS_IN_MONTH
let s:SECS_IN_YEAR = s:SECS_IN_DAY * s:DAYS_IN_YEAR

let s:PARSE_DUE_REGEX =
  \ '^:\(\d\{0,2}\)\(\d\{0,2}\)\(\d\{2}\)\?:\?\(\d\{0,2}\)\(\d\{0,2}\)$'

"------------------------------------------------------------------# Parse due #

function! kronos#tool#datetime#ParseDue(dateref, duestr)
  let l:matches = matchlist(a:duestr, s:PARSE_DUE_REGEX)
  return kronos#tool#datetime#ParseDueRecursive(a:dateref, 0, l:matches[1:5])
endfunction

function! kronos#tool#datetime#ParseDueRecursive(dateref, dateapprox, payload)
  let [l:day, l:month, l:year, l:hour, l:min] = a:payload
  let [l:dayref, l:monthref, l:yearref, l:hourref, l:minref] = 
    \ split(strftime('%d/%m/%y/%H/%M', a:dateref), '/')

  let l:daymatch = l:day == '' ? l:dayref : +l:day
  let l:monthmatch = l:month == '' ? l:monthref : +l:month
  let l:yearmatch = l:year == '' ? l:yearref : +l:year
  let l:hourmatch = l:hour == '' ? l:hourref : +l:hour
  let l:minmatch = l:min == '' ? 0 : +l:min

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

  if l:day != ''
    let l:dateapprox += (l:day - strftime('%d', l:dateapprox)) * s:SECS_IN_DAY
  endif

  let l:dateapprox += (l:hour - strftime('%H', l:dateapprox)) * s:SECS_IN_HOUR
  if  l:dateapprox == a:dateapprox | return l:dateapprox | endif

  return kronos#tool#datetime#ParseDueRecursive(a:dateref, l:dateapprox, [
    \ l:day,
    \ strftime('%m', l:dateapprox),
    \ strftime('%y', l:dateapprox),
    \ l:hour,
    \ strftime('%M', l:dateapprox),
  \])
endfunction

