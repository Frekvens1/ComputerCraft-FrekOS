from fastapi import UploadFile
from minio import Minio
from pydantic import BaseModel

from libraries import security_lib, environment_lib


class S3Bucket(BaseModel):
    name: str


class File(BaseModel):
    file_uuid: str
    filename: str


s3: Minio


def initialize():
    connect()


def connect() -> bool:
    global s3

    credentials = environment_lib.get_s3_credentials()

    s3 = Minio(
        f"{credentials.host}:{credentials.port}",
        access_key=credentials.access_key,
        secret_key=credentials.secret_key,
        secure=False
    )

    if s3 is None:
        return False

    return True


def create_bucket(bucket: S3Bucket):
    if not s3.bucket_exists(bucket.name):
        s3.make_bucket(bucket.name)


def upload(bucket: S3Bucket, file: UploadFile) -> File:
    create_bucket(bucket)
    file_uuid = str(security_lib.generate_uuid())

    s3.put_object(
        bucket.name,
        file_uuid,
        file.file,
        length=-1,  # unknown size → streaming
        part_size=10 * 1024 * 1024  # 10MB chunks
    )

    return File(
        file_uuid=file_uuid,
        filename=file.filename
    )

def download(bucket: S3Bucket, file_uuid: str):
    if not s3.bucket_exists(bucket.name):
        return None
    return s3.get_object(bucket.name, file_uuid)


def delete_file(bucket: S3Bucket, file_uuid: str):
    s3.remove_object(bucket.name, file_uuid)
