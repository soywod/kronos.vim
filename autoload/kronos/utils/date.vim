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
  let date_ref = strftime('%Y-%m-%d %H:%M', a:date_ref)
  let cmd = printf("parse_due('%s', '%s')", date_ref, a:due_str)
  return py3eval(cmd)
endfunction

function! kronos#utils#date#approx_due(date_ref, due_str)
  let date_ref = strftime('%Y-%m-%d %H:%M', a:date_ref)
  let cmd = printf("approx_due('%s', '%s')", date_ref, a:due_str)
  return py3eval(cmd)
endfunction

" ----------------------------------------------------------------- # Worktime #

function! kronos#utils#date#worktime(tasks, tags, min, max, date_ref)
  let worktimes = {}

  for task in a:tasks
    let match_tags = filter(copy(a:tags), 'index(task.tags, v:val) > -1')
    if match_tags != a:tags | continue | endif

    let starts = task.start
    let stops  = task.active ? task.stop + [a:date_ref] : task.stop

    for index in range(len(starts))
      let end_of_day = 0
      let start = copy(starts[index])
      let stop  = copy(stops[index])

      while end_of_day < stop
        if a:max > -1
          if start > a:max | return worktimes | endif
          if stop > a:max | let stop = a:max | endif
        endif

        if a:min > -1
          if start < a:min | let start = a:min | endif
          if stop < a:min | break | endif
        endif

        let [key, hour, min] = split(strftime('%d/%m/%y#%H#%M', start), '#')

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
