"------------------------------------------------------------------# Constants #

let s:SECS_IN_SEC    = 1
let s:SECS_IN_MIN    = 60
let s:MINS_IN_HOUR   = 60
let s:HOURS_IN_DAY   = 24
let s:DAYS_IN_WEEK   = 7
let s:DAYS_IN_MONTH  = 32
let s:DAYS_IN_YEAR   = 366

let s:PARSE_DUE_REGEX =
  \'^:\(\d\{0,2}\)\(\d\{0,2}\)\(\d\{2}\)\?:\?\(\d\{0,2}\)\(\d\{0,2}\)$'

let s:CONST = {
  \'DATE_FORMAT': '%c',
  \'SECONDE_IN': {
    \'SEC'  : s:SECS_IN_SEC,
    \'MIN'  : s:SECS_IN_MIN,
    \'HOUR' : s:SECS_IN_MIN * s:MINS_IN_HOUR,
    \'DAY'  : s:SECS_IN_MIN * s:MINS_IN_HOUR * s:HOURS_IN_DAY,
    \'WEEK' : s:SECS_IN_MIN * s:MINS_IN_HOUR * s:HOURS_IN_DAY * s:DAYS_IN_WEEK,
    \'MONTH': s:SECS_IN_MIN * s:MINS_IN_HOUR * s:HOURS_IN_DAY * s:DAYS_IN_MONTH,
    \'YEAR' : s:SECS_IN_MIN * s:MINS_IN_HOUR * s:HOURS_IN_DAY * s:DAYS_IN_YEAR,
  \},
  \'LABEL': {
    \'AGO': '%s ago',
    \'IN': 'in %s',
    \'UNIT': {
      \'SEC'  : '%ds',
      \'MIN'  : '%dmin',
      \'HOUR' : '%dh',
      \'DAY'  : '%dd',
      \'WEEK' : '%dw',
      \'MONTH': '%dmo',
      \'YEAR' : '%dy',
    \},
  \},
\}

function! kronos#tool#datetime#Const()
  return s:CONST
endfunction

"-------------------------------------------------------------# Get human date #

function! kronos#tool#datetime#GetHumanDate(date)
  return strftime(s:CONST.DATE_FORMAT, a:date)
endfunction

"--------------------------------------------------------# Get full human diff #

function! kronos#tool#datetime#GetFullHumanDiff(datesrc, datedest)
  let diffarr  = []
  let datediff = abs(a:datesrc - a:datedest)
  let units    = ['YEAR', 'MONTH', 'WEEK', 'DAY', 'HOUR', 'MIN', 'SEC']

  for unit in units
    let nbsec = s:CONST.SECONDE_IN[unit]
    let ratio = datediff / nbsec

    if ratio != 0
      let unitfmt   = s:CONST.LABEL.UNIT[unit]
      let unitstr   = printf(unitfmt, ratio)
      let diffarr  += [unitstr]
      let datediff -= (ratio * nbsec)
    endif
  endfor

  return join(diffarr, ' ')
endfunction

"-------------------------------------------------------------# Get human diff #

function! kronos#tool#datetime#GetHumanDiff(datesrc, datedest)
  let datediff  = abs(a:datesrc - a:datedest)
  let difffmt   = s:CONST.LABEL[a:datesrc < a:datedest ? 'IN' : 'AGO']
  let intervals = [
    \['SEC'  , 'MIN'  ],
    \['MIN'  , 'HOUR' ],
    \['HOUR' , 'DAY'  ],
    \['DAY'  , 'WEEK' ],
    \['WEEK' , 'MONTH'],
    \['MONTH', 'YEAR' ],
    \['YEAR' , 'YEAR' ],
  \]

  for [min, max] in intervals
    let secmin = s:CONST.SECONDE_IN[min]
    let secmax = s:CONST.SECONDE_IN[max]

    if datediff < secmax || min == 'YEAR'
      let value   = datediff / secmin + 1
      let unitfmt = s:CONST.LABEL.UNIT[min]
      let unitstr = printf(unitfmt, value)
      let diffstr = printf(difffmt, unitstr)

      return diffstr
    endif
  endfor
endfunction

"------------------------------------------------------------------# Parse due #

function! kronos#tool#datetime#ParseDue(dateref, duestr)
  let Parse = function('kronos#tool#datetime#ParseDueRecursive')

  let matches = matchlist(a:duestr, s:PARSE_DUE_REGEX)
  let due  = Parse(a:dateref, 0, l:matches[1:5])
  let due -= strftime('%S', due)

  return due
endfunction

function! kronos#tool#datetime#ParseDueRecursive(dateref, dateapprox, payload)
  let [l:day, l:month, l:year, l:hour, l:min] = a:payload
  let [l:dayref, l:monthref, l:yearref, l:hourref, l:minref] = split(
    \strftime('%d/%m/%y/%H/%M', a:dateref),
    \'/',
  \)

  let l:daymatch   = l:day   == '' ? l:dayref   : +l:day
  let l:monthmatch = l:month == '' ? l:monthref : +l:month
  let l:yearmatch  = l:year  == '' ? l:yearref  : +l:year
  let l:hourmatch  = l:hour  == '' ? l:hourref  : +l:hour
  let l:minmatch   = l:min   == '' ? 0          : +l:min

  let l:daydiff   = (l:daymatch - l:dayref)     * s:CONST.SECONDE_IN.DAY
  let l:monthdiff = (l:monthmatch - l:monthref) * s:CONST.SECONDE_IN.MONTH
  let l:yeardiff  = (l:yearmatch - l:yearref)   * s:CONST.SECONDE_IN.YEAR
  let l:hourdiff  = (l:hourmatch - l:hourref)   * s:CONST.SECONDE_IN.HOUR
  let l:mindiff   = (l:minmatch - l:minref)     * s:CONST.SECONDE_IN.MIN

  let l:diff = l:daydiff + l:monthdiff + l:yeardiff + l:mindiff + l:hourdiff
  if  l:diff == 0 | return a:dateref | endif

  if l:diff < 0
    if     l:yeardiff  < 0 | throw 'invalid-date'
    elseif l:monthdiff < 0 | let l:diff += s:CONST.SECONDE_IN.YEAR
    elseif l:daydiff   < 0 | let l:diff += s:CONST.SECONDE_IN.MONTH
    elseif l:hourdiff  < 0 | let l:diff += s:CONST.SECONDE_IN.DAY
    elseif l:mindiff   < 0 | let l:diff += s:CONST.SECONDE_IN.DAY
    endif
  endif

  let l:dateapprox = a:dateref + l:diff

  if l:day != ''
    let l:delta       = l:day - strftime('%d', l:dateapprox)
    let l:dateapprox += l:delta * s:CONST.SECONDE_IN.DAY
  endif

  let l:delta       = l:hour - strftime('%H', l:dateapprox)
  let l:dateapprox += l:delta * s:CONST.SECONDE_IN.HOUR
  if  l:dateapprox == a:dateapprox | return l:dateapprox | endif

  return kronos#tool#datetime#ParseDueRecursive(a:dateref, l:dateapprox, [
    \l:day,
    \strftime('%m', l:dateapprox),
    \strftime('%y', l:dateapprox),
    \l:hour,
    \strftime('%M', l:dateapprox),
  \])
endfunction

