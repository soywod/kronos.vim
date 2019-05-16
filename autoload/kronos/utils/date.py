from re import findall, match
from datetime import datetime
from datetime import timedelta

abs_due_regex = r'^[:<>](\d{0,2})(\d{0,2})(\d{2})?:?(\d{0,2})(\d{0,2})$'
rel_due_regex = r'^:(?:(\d+)y)?(?:(\d+)mo)?(?:(\d+)w)?(?:(\d+)d)?(?:(\d+)h)?(?:(\d+)m)?$'

secs_in_sec   = 1
secs_in_min   = 60
mins_in_hour  = 60
hours_in_day  = 24
days_in_month = 32
days_in_year  = 366

config = dict({
  'msec_in': {
    'sec'  : secs_in_sec,
    'min'  : secs_in_min,
    'hour' : secs_in_min * mins_in_hour,
    'day'  : secs_in_min * mins_in_hour * hours_in_day,
    'month': secs_in_min * mins_in_hour * hours_in_day * days_in_month,
    'year' : secs_in_min * mins_in_hour * hours_in_day * days_in_year,
  },
  'label': {
    'ago': '%s ago',
    'in': 'in %s',
    'unit': {
      'sec'  : '%ds',
      'min'  : '%dmin',
      'hour' : '%dh',
      'day'  : '%dd',
      'month': '%dmo',
      'year' : '%dy',
    },
  },
})

def _parse_fix_due(date_ref, due_str):
    matches = findall(abs_due_regex, due_str)[0]
    day = int(matches[0]) if matches[0] else date_ref.day
    month = int(matches[1]) if matches[1] else date_ref.month
    year = datetime.strptime(matches[2], '%y').year if matches[2] else date_ref.year
    hour = int(matches[3]) if matches[3] else 0
    minute = int(matches[4]) if matches[4] else 0

    return datetime(year, month, day, hour, minute)

def parse_due(date_ref, due_str):
    date_ref = datetime.fromtimestamp(date_ref)
    date_due = _parse_fix_due(date_ref, due_str)

    return int(date_due.timestamp())

def approx_due(date_ref, due_str):
    date_ref = datetime.fromtimestamp(date_ref)
    
    if match(abs_due_regex, due_str):
        date_due = _parse_fix_due(date_ref, due_str)

        if date_due >= date_ref:
            return int(date_due.timestamp())
        elif date_due.year < date_ref.year:
            raise Exception('invalid date')
        elif date_due.month < date_ref.month:
            date_due = date_due.replace(year=date_due.year + 1)
        elif date_due.day < date_ref.day:
            if date_due.month == 12:
                date_due = date_due.replace(month=1, year=date_due.year + 1)
            else:
                date_due = date_due.replace(month=date_due.month + 1)
        elif date_due.hour < date_ref.hour:
            date_due += timedelta(days=1)
        elif date_due.minute < date_ref.minute:
            date_due += timedelta(days=1)

        return int(date_due.timestamp())

    elif match(rel_due_regex, due_str):
        date_due = date_ref
        matches = findall(rel_due_regex, due_str)[0]
        years = int(matches[0]) if matches[0] else 0
        months = int(matches[1]) if matches[1] else 0
        weeks = int(matches[2]) if matches[2] else 0
        days = int(matches[3]) if matches[3] else 0
        hours = int(matches[4]) if matches[4] else 0
        minutes = int(matches[5]) if matches[5] else 0
        
        date_due += timedelta(days=7 * weeks + days, hours=hours, minutes=minutes)

        next_months = (date_due.month + months) % 12
        next_years = date_due.year + years + int((date_due.month + months) / 12)
        date_due = date_due.replace(month=next_months, year=next_years)

        return int(date_due.timestamp())
    else:
        raise Exception('invalid due')

def duration(total_secs):
    duration = []

    for unit in ['year', 'month', 'day', 'hour', 'min', 'sec']:
        curr_secs = config['msec_in'][unit]
        ratio = int(total_secs / curr_secs)

        if ratio == 0:
            continue

        unit_format = config['label']['unit'][unit]
        duration += [unit_format % ratio]
        total_secs -= ratio * curr_secs

    return ' '.join(duration)

def relative(date_src, date_dest):
    total_secs = abs(date_src - date_dest)
    relative_fmt  = config['label']['in' if date_src < date_dest else 'ago']

    for unit in ['year', 'month', 'day', 'hour', 'min', 'sec']:
        curr_secs = config['msec_in'][unit]
        ratio = int(total_secs / curr_secs)

        if ratio == 0:
            continue

        unit_format = config['label']['unit'][unit]
        duration_str = unit_format % (ratio + 1)

        return relative_fmt % duration_str

    return 'just now'

def worktime(date_ref, tasks, tags, date_min, date_max):
    worktimes = {}

    for task in tasks:
        if tags and not set(task['tags']).intersection(tags):
            continue

        starts = task['start']
        stops  = task['stop'] if not task['active'] else task['stop'] + [date_ref]

        for index in range(len(starts)):
            end_of_day = 0
            start = starts[index]
            stop  = stops[index]

            while end_of_day < stop:
                if date_max > -1:
                  if start > date_max: return worktimes
                  if stop > date_max: stop = date_max

                if date_min > -1:
                    if start < date_min: start = date_min
                    if stop < date_min: break

                date_start = datetime.fromtimestamp(start)
                key = date_start.strftime('%d/%m/%y')

                end_hour = (23 - date_start.hour) * config['msec_in']['hour']
                end_min = (59 - date_start.minute) * config['msec_in']['min']
                end_of_day = start + end_hour + end_min
                min_stop = stop if stop < end_of_day else end_of_day

                if key not in worktimes: worktimes[key] = 0
                worktimes[key] += (min_stop - start)
                start = end_of_day + config['msec_in']['min']

    return worktimes
