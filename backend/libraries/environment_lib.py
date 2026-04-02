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


class S3Credentials(BaseModel):
    host: str
    port: int
    access_key: str
    secret_key: str


def get_s3_credentials() -> S3Credentials:
    return S3Credentials(
        host=str(os.environ['S3_HOST']),
        port=int(os.environ['S3_PORT']),
        access_key=str(os.environ['S3_ACCESS_KEY']),
        secret_key=str(os.environ['S3_SECRET_KEY']),
    )
