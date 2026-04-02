from typing import List, Optional

from fastapi import UploadFile
from starlette.responses import StreamingResponse

from libraries import mongo_lib, security_lib, s3_lib, ffmpeg_lib
from libraries.s3_lib import S3Bucket, FileData
from modules.music.models import DFPWM, Playlist, PlaylistData, DFPWMData

dfpwm_bucket = S3Bucket(
    name="dfpwm",
)


def playlist_collection():
    return mongo_lib.mongo_collection(
        mongo_lib.MongoCollection(
            database='music',
            collection='playlists'
        ))


def dfpwm_collection():
    return mongo_lib.mongo_collection(
        mongo_lib.MongoCollection(
            database='music',
            collection='dfpwm'
        ))


# region { Music - Playlist }

def get_all_playlists() -> List[Playlist]:
    docs = list(playlist_collection().find({}))
    return [Playlist(**doc) for doc in docs]


def create_playlist(playlist_data: PlaylistData) -> Playlist:
    playlist = Playlist(
        playlist_uuid=str(security_lib.generate_uuid()),
        **playlist_data.model_dump(exclude_none=True),
    )
    result = playlist_collection().insert_one(playlist.model_dump(exclude_none=True))

    created = playlist_collection().find_one({"_id": result.inserted_id})
    return Playlist(**created)


def get_playlist(playlist_uuid: str) -> Optional[Playlist]:
    doc = playlist_collection().find_one({'playlist_uuid': playlist_uuid})
    return Playlist(**doc) if doc else None


def update_playlist(playlist_uuid: str, playlist_data: PlaylistData) -> Playlist:
    playlist_collection().update_one(
        {'playlist_uuid': playlist_uuid},
        {'$set': playlist_data.model_dump(exclude_none=True)},
    )
    updated = playlist_collection().find_one({'playlist_uuid': playlist_uuid})
    return Playlist(**updated) if updated else None


def patch_playlist(playlist_uuid: str, playlist_data: PlaylistData) -> Playlist:
    playlist_collection().update_one(
        {'playlist_uuid': playlist_uuid},
        {'$set': playlist_data.model_dump(exclude_none=True)}
    )
    updated = playlist_collection().find_one({'playlist_uuid': playlist_uuid})
    return Playlist(**updated) if updated else None


def delete_playlist(playlist_uuid: str) -> bool:
    result = playlist_collection().delete_one({'playlist_uuid': playlist_uuid})
    return result.deleted_count > 0


# endregion

# region { Music - DFPWM }

def get_all_dfpwm() -> List[DFPWM]:
    docs = list(dfpwm_collection().find({}))
    return [DFPWM(**doc) for doc in docs]


def get_dfpwm_stream(dfpwm_uuid: str) -> Optional[StreamingResponse]:
    dfpwm = get_dfpwm(dfpwm_uuid)
    if not dfpwm:
        return None

    return StreamingResponse(
        s3_lib.download(dfpwm_bucket, dfpwm.file_uuid),
        media_type="audio/dfpwm"
    )


def get_dfpwm_download(dfpwm_uuid: str):
    dfpwm = get_dfpwm(dfpwm_uuid)
    if not dfpwm:
        return None

    return StreamingResponse(
        s3_lib.download(dfpwm_bucket, dfpwm.file_uuid),
        media_type="application/octet-stream",
        headers={
            "Content-Disposition": f'attachment; filename="{dfpwm.filename}"'
        }
    )


def create_dfpwm(dfpwm_data: DFPWMData, file: UploadFile) -> DFPWM:
    file_data = FileData(
        filename=file.filename,
        data_stream=file.file,
    )

    file_type = file.filename.lower().rsplit(".", 1)[-1]
    if not file_type.lower() == "dfpwm":
        file_data = ffmpeg_lib.convert_to_dfpwm(file_data)

    file_details = s3_lib.upload(dfpwm_bucket, file_data)

    dfpwm = DFPWM(
        dfpwm_uuid=str(security_lib.generate_uuid()),
        file_uuid=str(file_details.file_uuid),
        filename=str(file_details.filename),
        size=file_details.size,
        **dfpwm_data.model_dump(exclude_none=True),
    )
    result = dfpwm_collection().insert_one(dfpwm.model_dump(exclude_none=True))

    created = dfpwm_collection().find_one({"_id": result.inserted_id})
    return DFPWM(**created)


def get_dfpwm(dfpwm_uuid: str) -> Optional[DFPWM]:
    doc = dfpwm_collection().find_one({'dfpwm_uuid': dfpwm_uuid})
    return DFPWM(**doc) if doc else None


def update_dfpwm(dfpwm_uuid: str, dfpwm_data: DFPWMData) -> DFPWM:
    dfpwm_collection().update_one(
        {'dfpwm_uuid': dfpwm_uuid},
        {'$set': dfpwm_data.model_dump(exclude_none=True)},
    )
    updated = dfpwm_collection().find_one({'dfpwm_uuid': dfpwm_uuid})
    return DFPWM(**updated) if updated else None


def patch_dfpwm(dfpwm_uuid: str, dfpwm_data: DFPWMData) -> DFPWM:
    dfpwm_collection().update_one(
        {'dfpwm_uuid': dfpwm_uuid},
        {'$set': dfpwm_data.model_dump(exclude_none=True)}
    )
    updated = dfpwm_collection().find_one({'dfpwm_uuid': dfpwm_uuid})
    return DFPWM(**updated) if updated else None


def delete_dfpwm(dfpwm_uuid: str) -> bool:
    dfpwm = get_dfpwm(dfpwm_uuid)
    if not dfpwm:
        return False

    s3_lib.delete_file(dfpwm_bucket, dfpwm.file_uuid)
    result = dfpwm_collection().delete_one({'dfpwm_uuid': dfpwm_uuid})
    return result.deleted_count > 0

# endregion
