" ---------------------------------------------------------------- # Constants #

let s:SECS_IN_SEC   = 1
let s:SECS_IN_MIN   = 60
let s:MINS_IN_HOUR  = 60
let s:HOURS_IN_DAY  = 24
let s:DAYS_IN_WEEK  = 7
let s:DAYS_IN_MONTH = 32
let s:DAYS_IN_YEAR  = 366

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

" ----------------------------------------------------------- # Get human date #

function! kronos#tool#datetime#PrintDate(date)
  return strftime(s:CONST.DATE_FORMAT, a:date)
endfunction

" --------------------------------------------------------- # Print human time #

function! kronos#tool#datetime#PrintInterval(interval)
  let interval = a:interval
  let diffarr  = []

  for unit in ['YEAR', 'MONTH', 'WEEK', 'DAY', 'HOUR', 'MIN', 'SEC']
    let nbsec = s:CONST.SECONDE_IN[unit]
    let ratio = interval / nbsec

    if ratio != 0
      let unitfmt   = s:CONST.LABEL.UNIT[unit]
      let unitstr   = printf(unitfmt, ratio)
      let diffarr  += [unitstr]
      let interval -= (ratio * nbsec)
    endif
  endfor

  return join(diffarr, ' ')
endfunction

" --------------------------------------------------------------- # Print diff #

function! kronos#tool#datetime#PrintDiff(datesrc, datedest)
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

" ---------------------------------------------------------------- # Parse due #

function! kronos#tool#datetime#ParseDue(dateref, duestr)
  let matches = matchlist(a:duestr, s:PARSE_DUE_REGEX)
  let due  = kronos#tool#datetime#ParseDueRecursive(a:dateref, 0, matches[1:5])
  let due -= strftime('%S', due)

  return due
endfunction

function! kronos#tool#datetime#ParseDueRecursive(dateref, dateapprox, payload)
  let [day, month, year, hour, min] = a:payload
  let [dayref, monthref, yearref, hourref, minref] = split(
    \strftime('%d/%m/%y/%H/%M', a:dateref),
    \'/',
  \)

  let daymatch   = day   == '' ? dayref   : +day
  let monthmatch = month == '' ? monthref : +month
  let yearmatch  = year  == '' ? yearref  : +year
  let hourmatch  = hour  == '' ? hourref  : +hour
  let minmatch   = min   == '' ? 0        : +min

  let daydiff   = (daymatch - dayref)     * s:CONST.SECONDE_IN.DAY
  let monthdiff = (monthmatch - monthref) * s:CONST.SECONDE_IN.MONTH
  let yeardiff  = (yearmatch - yearref)   * s:CONST.SECONDE_IN.YEAR
  let hourdiff  = (hourmatch - hourref)   * s:CONST.SECONDE_IN.HOUR
  let mindiff   = (minmatch - minref)     * s:CONST.SECONDE_IN.MIN

  let diff = daydiff + monthdiff + yeardiff + mindiff + hourdiff
  if  diff == 0 | return a:dateref | endif

  if diff < 0
    if     yeardiff  < 0 | throw 'invalid-date'
    elseif monthdiff < 0 | let diff += s:CONST.SECONDE_IN.YEAR
    elseif daydiff   < 0 | let diff += s:CONST.SECONDE_IN.MONTH
    elseif hourdiff  < 0 | let diff += s:CONST.SECONDE_IN.DAY
    elseif mindiff   < 0 | let diff += s:CONST.SECONDE_IN.DAY
    endif
  endif

  let dateapprox = a:dateref + diff

  if day != ''
    let delta       = day - strftime('%d', dateapprox)
    let dateapprox += delta * s:CONST.SECONDE_IN.DAY
  endif

  let delta       = hour - strftime('%H', dateapprox)
  let dateapprox += delta * s:CONST.SECONDE_IN.HOUR
  if  dateapprox == a:dateapprox | return dateapprox | endif

  return kronos#tool#datetime#ParseDueRecursive(a:dateref, dateapprox, [
    \day,
    \strftime('%m', dateapprox),
    \strftime('%y', dateapprox),
    \hour,
    \strftime('%M', dateapprox),
  \])
endfunction

