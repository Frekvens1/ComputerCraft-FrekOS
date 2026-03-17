import datetime

def get_timestamp():
    return datetime.datetime.now(tz=datetime.timezone.utc)
