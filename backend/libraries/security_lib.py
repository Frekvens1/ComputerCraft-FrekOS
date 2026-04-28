import hashlib
import os
import uuid


def generate_uuid():
    # https://stackoverflow.com/questions/817882/unique-session-id-in-python/55661405#55661405
    # https://docs.python.org/3/library/uuid.html#uuid.uuid4
    return str(uuid.uuid4())  # Generate a random UUID


def salt() -> str:
    return os.urandom(16).hex()


def sha256(text: str) -> str:
    return hashlib.sha256(text.encode('utf-8')).hexdigest()
