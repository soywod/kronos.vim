" ------------------------------------------------------------------- # Config #

let s:secs_in_sec   = 1
let s:secs_in_min   = 60
let s:mins_in_hour  = 60
let s:hours_in_day  = 24
let s:days_in_week  = 7
let s:days_in_month = 32
let s:days_in_year  = 366

let s:parse_due_regex =
  \'^:\(\d\{0,2}\)\(\d\{0,2}\)\(\d\{2}\)\?:\?\(\d\{0,2}\)\(\d\{0,2}\)$'

let s:config = {
  \'date_format': '%c',
  \'second_in': {
    \'sec'  : s:secs_in_sec,
    \'min'  : s:secs_in_min,
    \'hour' : s:secs_in_min * s:mins_in_hour,
    \'day'  : s:secs_in_min * s:mins_in_hour * s:hours_in_day,
    \'week' : s:secs_in_min * s:mins_in_hour * s:hours_in_day * s:days_in_week,
    \'month': s:secs_in_min * s:mins_in_hour * s:hours_in_day * s:days_in_month,
    \'year' : s:secs_in_min * s:mins_in_hour * s:hours_in_day * s:days_in_year,
  \},
  \'label': {
    \'ago': '%s ago',
    \'in': 'in %s',
    \'unit': {
      \'sec'  : '%ds',
      \'min'  : '%dmin',
      \'hour' : '%dh',
      \'day'  : '%dd',
      \'week' : '%dw',
      \'month': '%dmo',
      \'year' : '%dy',
    \},
  \},
\}

function! kronos#utils#datetime#config()
  return s:config
endfunction

" ----------------------------------------------------------- # Get human date #

function! kronos#utils#datetime#print_date(date)
  return strftime(s:config.date_format, a:date)
endfunction

" --------------------------------------------------------- # Print human time #

function! kronos#utils#datetime#print_interval(interval)
  let interval = a:interval
  let diffarr  = []

  for unit in ['year', 'month', 'week', 'day', 'hour', 'min', 'sec']
    let nbsec = s:config.second_in[unit]
    let ratio = interval / nbsec

    if ratio != 0
      let unitfmt   = s:config.label.unit[unit]
      let unitstr   = printf(unitfmt, ratio)
      let diffarr  += [unitstr]
      let interval -= (ratio * nbsec)
    endif
  endfor

  return join(diffarr, ' ')
endfunction

" --------------------------------------------------------------- # Print diff #

function! kronos#utils#datetime#print_diff(datesrc, datedest)
  let datediff  = abs(a:datesrc - a:datedest)
  let difffmt   = s:config.label[a:datesrc < a:datedest ? 'in' : 'ago']
  let intervals = [
    \['sec'  , 'min'  ],
    \['min'  , 'hour' ],
    \['hour' , 'day'  ],
    \['day'  , 'week' ],
    \['week' , 'month'],
    \['month', 'year' ],
    \['year' , 'year' ],
  \]

  for [min, max] in intervals
    let secmin = s:config.second_in[min]
    let secmax = s:config.second_in[max]

    if datediff < secmax || min == 'year'
      let value   = datediff / secmin + 1
      let unitfmt = s:config.label.unit[min]
      let unitstr = printf(unitfmt, value)
      let diffstr = printf(difffmt, unitstr)

      return diffstr
    endif
  endfor
endfunction

" ---------------------------------------------------------------- # Parse due #

function! kronos#utils#datetime#parse_due(dateref, duestr)
  let matches = matchlist(a:duestr, s:parse_due_regex)
  let due  = kronos#utils#datetime#parse_due_recursive(a:dateref, 0, matches[1:5])
  let due -= strftime('%S', due)

  return due
endfunction

function! kronos#utils#datetime#parse_due_recursive(dateref, dateapprox, payload)
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

  let daydiff   = (daymatch - dayref)     * s:config.second_in.day
  let monthdiff = (monthmatch - monthref) * s:config.second_in.month
  let yeardiff  = (yearmatch - yearref)   * s:config.second_in.year
  let hourdiff  = (hourmatch - hourref)   * s:config.second_in.hour
  let mindiff   = (minmatch - minref)     * s:config.second_in.min

  let diff = daydiff + monthdiff + yeardiff + mindiff + hourdiff
  if  diff == 0 | return a:dateref | endif

  if diff < 0
    if     yeardiff  < 0 | throw 'invalid-date'
    elseif monthdiff < 0 | let diff += s:config.second_in.year
    elseif daydiff   < 0 | let diff += s:config.second_in.month
    elseif hourdiff  < 0 | let diff += s:config.second_in.day
    elseif mindiff   < 0 | let diff += s:config.second_in.day
    endif
  endif

  let dateapprox = a:dateref + diff

  if day != ''
    let delta       = day - strftime('%d', dateapprox)
    let dateapprox += delta * s:config.second_in.day
  endif

  let delta       = hour - strftime('%H', dateapprox)
  let dateapprox += delta * s:config.second_in.hour
  if  dateapprox == a:dateapprox | return dateapprox | endif

  return kronos#utils#datetime#parse_due_recursive(a:dateref, dateapprox, [
    \day,
    \strftime('%m', dateapprox),
    \strftime('%y', dateapprox),
    \hour,
    \strftime('%M', dateapprox),
  \])
endfunction
