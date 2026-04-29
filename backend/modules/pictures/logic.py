from io import BytesIO
from pathlib import Path
from typing import List, Optional

from fastapi import UploadFile
from starlette.responses import StreamingResponse

from libraries import mongo_lib, security_lib, s3_lib, sanjuuni_lib
from libraries.s3_lib import S3Bucket, FileData
from modules.pictures.models import CCPicture, CCPictureData

picture_bucket = S3Bucket(
    name="pictures",
)


def picture_collection():
    return mongo_lib.mongo_collection(
        mongo_lib.MongoCollection(
            database='pictures',
            collection='bimg'
        ))


# region { Pictures - BIMG }

def get_all_pictures() -> List[CCPicture]:
    docs = list(picture_collection().find({}))
    return [CCPicture(**doc) for doc in docs]


def get_picture_download(picture_uuid: str):
    picture = get_picture(picture_uuid)
    if not picture:
        return None

    return StreamingResponse(
        s3_lib.download(picture_bucket, picture.file_uuid),
        media_type="application/octet-stream",
        headers={
            "Content-Disposition": f'attachment; filename="{picture.filename}"'
        }
    )


async def create_picture(picture_data: CCPictureData, file: UploadFile) -> CCPicture | None:
    img_bytes = await file.read()
    bimg_bytes = await sanjuuni_lib.convert_image(img_bytes)

    if type(bimg_bytes) is not bytes:
        return None

    file_data = FileData(
        filename=str(Path(file.filename).with_suffix(".bimg")),
        data_stream=BytesIO(bimg_bytes),
    )

    file_details = s3_lib.upload(picture_bucket, file_data)

    picture = CCPicture(
        picture_uuid=str(security_lib.generate_uuid()),
        file_uuid=str(file_details.file_uuid),
        filename=str(file_details.filename),
        size=file_details.size,
        **picture_data.model_dump(exclude_none=True),
    )
    result = picture_collection().insert_one(picture.model_dump(exclude_none=True))

    created = picture_collection().find_one({"_id": result.inserted_id})
    return CCPicture(**created)


def get_picture(picture_uuid: str) -> Optional[CCPicture]:
    doc = picture_collection().find_one({'picture_uuid': picture_uuid})
    return CCPicture(**doc) if doc else None


def update_picture(picture_uuid: str, picture_data: CCPictureData) -> CCPicture:
    picture_collection().update_one(
        {'picture_uuid': picture_uuid},
        {'$set': picture_data.model_dump(exclude_none=True)},
    )
    updated = picture_collection().find_one({'picture_uuid': picture_uuid})
    return CCPicture(**updated) if updated else None


def patch_picture(picture_uuid: str, picture_data: CCPictureData) -> CCPicture:
    picture_collection().update_one(
        {'picture_uuid': picture_uuid},
        {'$set': picture_data.model_dump(exclude_none=True)}
    )
    updated = picture_collection().find_one({'picture_uuid': picture_uuid})
    return CCPicture(**updated) if updated else None


def delete_picture(picture_uuid: str) -> bool:
    picture = get_picture(picture_uuid)
    if not picture:
        return False

    s3_lib.delete_file(picture_bucket, picture.file_uuid)
    result = picture_collection().delete_one({'picture_uuid': picture_uuid})
    return result.deleted_count > 0

# endregion
