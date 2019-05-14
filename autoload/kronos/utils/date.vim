" ------------------------------------------------------------------- # Config #

exec 'py3file ' . resolve(expand('<sfile>:h') . '/date.py')

let s:secs_in_sec   = 1
let s:secs_in_min   = 60
let s:mins_in_hour  = 60
let s:hours_in_day  = 24
let s:days_in_month = 32
let s:days_in_year  = 366

let s:config = {
  \'date_format': '%c',
  \'msec_in': {
    \'sec'  : s:secs_in_sec,
    \'min'  : s:secs_in_min,
    \'hour' : s:secs_in_min * s:mins_in_hour,
    \'day'  : s:secs_in_min * s:mins_in_hour * s:hours_in_day,
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
      \'month': '%dmo',
      \'year' : '%dy',
    \},
  \},
\}

function! kronos#utils#date#config()
  return s:config
endfunction

" ----------------------------------------------------------------- # Duration #

function! kronos#utils#date#duration(seconds)
  let cmd = printf('duration(%d)', a:seconds)
  return py3eval(cmd)
endfunction

" ----------------------------------------------------------------- # Relative #

function! kronos#utils#date#relative(date_src, date_dest)
  let cmd = printf('relative(%d, %d)', a:date_src, a:date_dest)
  return py3eval(cmd)
endfunction

" ---------------------------------------------------------------- # Parse due #

function! kronos#utils#date#parse_due(date_ref, due_str)
  let cmd = printf("parse_due(%d, '%s')", a:date_ref, a:due_str)
  return py3eval(cmd)
endfunction

function! kronos#utils#date#approx_due(date_ref, due_str)
  let cmd = printf("approx_due(%d, '%s')", a:date_ref, a:due_str)
  return py3eval(cmd)
endfunction

" ----------------------------------------------------------------- # Worktime #

function! kronos#utils#date#worktime(date_ref, tasks, tags, min, max)
  let cmd = printf(
    \"worktime(%d, %s, %s, %d, %d)",
    \a:date_ref, string(a:tasks), string(a:tags), a:min, a:max,
  \)

  return py3eval(cmd)
endfunction
