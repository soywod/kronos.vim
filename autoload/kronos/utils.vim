let s:strftime = function('kronos#utils#date#strftime')

" ------------------------------------------------------------------- # Config #

let s:secs_in_sec   = 1
let s:secs_in_min   = 60
let s:mins_in_hour  = 60
let s:hours_in_day  = 24
let s:days_in_month = 32
let s:days_in_year  = 366

let s:parse_due_regex =
  \'^:\(\d\{0,2}\)\(\d\{0,2}\)\(\d\{2}\)\?:\?\(\d\{0,2}\)\(\d\{0,2}\)$'

let s:config = {
  \'date_format': '%c',
  \'msec_in': {
    \'sec'  : 1000 * s:secs_in_sec,
    \'min'  : 1000 * s:secs_in_min,
    \'hour' : 1000 * s:secs_in_min * s:mins_in_hour,
    \'day'  : 1000 * s:secs_in_min * s:mins_in_hour * s:hours_in_day,
    \'month': 1000 * s:secs_in_min * s:mins_in_hour * s:hours_in_day * s:days_in_month,
    \'year' : 1000 * s:secs_in_min * s:mins_in_hour * s:hours_in_day * s:days_in_year,
  \},
  \'label': {
    \'ago': '%s ago',
    \'in': 'in %s',
    \'unit': {
      \'sec'  : '%ds',
      \'min'  : '%dmin',
      \'hour' : '%dh',
      \'day'  : '%dd',
      \'month': '%dmo',
      \'year' : '%dy',
    \},
  \},
\}

function! kronos#utils#config()
  return s:config
endfunction

" ------------------------------------------------------------------ # Compose #

function! kronos#utils#compose(...)
  let funcs = map(reverse(copy(a:000)), 'function(v:val)')
  return function('s:compose', [funcs])
endfunction

function! s:compose(funcs, arg)
  let data = a:arg

  for Func in a:funcs
    let data = Func(data)
  endfor

  return data
endfunction

" --------------------------------------------------------------------- # Trim #

function! kronos#utils#trim(str)
  return kronos#utils#compose('s:trim_left', 's:trim_right')(a:str)
endfunction

function! s:trim_left(str)
  return substitute(a:str, '^\s*', '', 'g')
endfunction

function! s:trim_right(str)
  return substitute(a:str, '\s*$', '', 'g')
endfunction

" ------------------------------------------------------------------- # Assign #

function! kronos#utils#assign(...)
  let overrides = copy(a:000)
  let base = remove(overrides, 0)

  for override in overrides
    for [key, val] in items(override)
      let base[key] = val
      unlet key val
    endfor
  endfor

  return base
endfunction

" ---------------------------------------------------------------------- # Sum #

function! kronos#utils#sum(array)
  let total = 0

  for item in a:array
    let total += item
  endfor

  return total
endfunction

" ---------------------------------------------------------------- # Parse due #

function! kronos#utils#parse_due(date_ref, due_str)
  let matches = matchlist(a:due_str, s:parse_due_regex)
  let due  = s:parse_due(a:date_ref, 0, matches[1:5])
  let due -= s:strftime('%S', due)

  return due
endfunction

function! s:parse_due(dateref, dateapprox, payload)
  let [day, month, year, hour, min] = a:payload
  let [dayref, monthref, yearref, hourref, minref] = split(
    \s:strftime('%d/%m/%y/%H/%M', a:dateref),
    \'/',
  \)

  let daymatch   = day   == '' ? dayref   : +day
  let monthmatch = month == '' ? monthref : +month
  let yearmatch  = year  == '' ? yearref  : +year
  let hourmatch  = hour  == '' ? hourref  : +hour
  let minmatch   = min   == '' ? 0        : +min

  let daydiff   = (daymatch - dayref)     * s:config.msec_in.day
  let monthdiff = (monthmatch - monthref) * s:config.msec_in.month
  let yeardiff  = (yearmatch - yearref)   * s:config.msec_in.year
  let hourdiff  = (hourmatch - hourref)   * s:config.msec_in.hour
  let mindiff   = (minmatch - minref)     * s:config.msec_in.min

  let diff = daydiff + monthdiff + yeardiff + mindiff + hourdiff
  if  diff == 0 | return a:dateref | endif

  if diff < 0
    if     yeardiff  < 0 | throw 'invalid-date'
    elseif monthdiff < 0 | let diff += s:config.msec_in.year
    elseif daydiff   < 0 | let diff += s:config.msec_in.month
    elseif hourdiff  < 0 | let diff += s:config.msec_in.day
    elseif mindiff   < 0 | let diff += s:config.msec_in.day
    endif
  endif

  let dateapprox = a:dateref + diff

  if day != ''
    let delta       = day - s:strftime('%d', dateapprox)
    let dateapprox += delta * s:config.msec_in.day
  endif

  let delta       = hour - s:strftime('%H', dateapprox)
  let dateapprox += delta * s:config.msec_in.hour

  if  dateapprox == a:dateapprox | return dateapprox | endif

  return s:parse_due(a:dateref, dateapprox, [
    \day,
    \s:strftime('%m', dateapprox),
    \s:strftime('%y', dateapprox),
    \hour,
    \s:strftime('%M', dateapprox),
  \])
endfunction

" --------------------------------------------------------------- # Date utils #

function! kronos#utils#date(date)
  return s:strftime(s:config.date_format, a:date)
endfunction

function! kronos#utils#date_diff(datesrc, datedest)
  let datediff  = abs(a:datesrc - a:datedest)
  let difffmt   = s:config.label[a:datesrc < a:datedest ? 'in' : 'ago']
  let intervals = [
    \['sec'  , 'min'  ],
    \['min'  , 'hour' ],
    \['hour' , 'day'  ],
    \['day'  , 'month' ],
    \['month', 'year' ],
    \['year' , 'year' ],
  \]

  for [min, max] in intervals
    let secmin = s:config.msec_in[min]
    let secmax = s:config.msec_in[max]

    if datediff < secmax || min == 'year'
      let value   = datediff / secmin
      let unitfmt = s:config.label.unit[min]
      let unitstr = printf(unitfmt, value)
      let diffstr = printf(difffmt, unitstr)

      return diffstr
    endif
  endfor
endfunction

function! kronos#utils#date_interval(interval)
  let interval = a:interval
  let diffarr  = []

  for unit in ['year', 'month', 'day', 'hour', 'min', 'sec']
    let nbsec = s:config.msec_in[unit]
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

" ----------------------------------------------------------------- # Worktime #

function! kronos#utils#worktime(tasks, tags, date_ref)
  let worktimes = {}

  for task in a:tasks
    let match_tags = filter(copy(a:tags), 'index(task.tags, v:val) > -1')
    if match_tags != a:tags | continue | endif

    let starts = task.start
    let stops  = task.active ? task.stop + [a:date_ref] : task.stop

    for index in range(len(starts))
      let end_of_day = 0
      let start = starts[index]
      let stop  = stops[index]

      while end_of_day < stop
        let [key, hour, min] = split(s:strftime('%d/%m/%y#%H#%M', start), '#')

        let end_hour = (23 - hour) * s:config.msec_in.hour
        let end_min = (59 - min) * s:config.msec_in.min
        let end_of_day = start + end_hour + end_min
        let min_stop = stop < end_of_day ? stop : end_of_day

        if !has_key(worktimes, key) | let worktimes[key] = 0 | endif
        let worktimes[key] += (min_stop - start)
        let start = end_of_day + s:config.msec_in.min
      endwhile
    endfor
  endfor

  return worktimes
endfunction

" ---------------------------------------------------------------- # Log utils #

function! kronos#utils#log(msg)
  echom a:msg
endfunction

function! kronos#utils#error_log(msg)
  redraw
  echohl ErrorMsg
  echom 'Kronos: ' . a:msg . '.'
  echohl None
endfunction
