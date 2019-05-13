from re import findall
from datetime import datetime
from datetime import timedelta

due_regex = r'^[:<>](\d{0,2})(\d{0,2})(\d{2})?:?(\d{0,2})(\d{0,2})$'

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
