import uuid


def generate_uuid():
    # https://stackoverflow.com/questions/817882/unique-session-id-in-python/55661405#55661405
    # https://docs.python.org/3/library/uuid.html#uuid.uuid4
    return str(uuid.uuid4()) # Generate a random UUID
