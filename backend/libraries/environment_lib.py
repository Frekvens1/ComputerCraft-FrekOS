import os

from pydantic import BaseModel


class MongoDBCredentials(BaseModel):
    host: str
    port: int
    username: str
    password: str


def get_mongodb_credentials() -> MongoDBCredentials:
    return MongoDBCredentials(
        host=str(os.environ['MONGO_HOST']),
        port=int(os.environ['MONGO_PORT']),
        username=str(os.environ['MONGO_USERNAME']),
        password=str(os.environ['MONGO_PASSWORD']),
    )
