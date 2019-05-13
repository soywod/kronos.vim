from re import findall
from datetime import datetime
from datetime import timedelta

due_regex = r'^[:<>](\d{0,2})(\d{0,2})(\d{2})?:?(\d{0,2})(\d{0,2})$'

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

def _parse_due(date_ref, due_str):
    matches = findall(due_regex, due_str)[0]
    day = int(matches[0]) if matches[0] else date_ref.day
    month = int(matches[1]) if matches[1] else date_ref.month
    year = datetime.strptime(matches[2], '%y').year if matches[2] else date_ref.year
    hour = int(matches[3]) if matches[3] else 0
    minute = int(matches[4]) if matches[4] else 0

    return datetime(year, month, day, hour, minute)

def parse_due(date_ref, due_str):
    date_ref = datetime.fromisoformat(date_ref)
    date_due = _parse_due(date_ref, due_str)

    return int(date_due.timestamp())

def approx_due(date_ref, due_str):
    date_ref = datetime.fromisoformat(date_ref)
    date_due = _parse_due(date_ref, due_str)

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

    return ''
