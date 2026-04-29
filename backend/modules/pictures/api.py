import json
from typing import List

from fastapi import FastAPI, UploadFile
from fastapi.params import Form, File

from modules.common.models import DeleteResponse
from modules.pictures import logic
from modules.pictures.models import CCPicture, CCPictureData


def initialize(app: FastAPI):
    # region { Pictures }

    @app.get("/pictures", response_model=List[CCPicture], response_model_exclude_none=True)
    async def get_all_pictures():
        return logic.get_all_pictures()

    @app.get("/picture/{picture_uuid}/bimg", response_model=List[CCPicture], response_model_exclude_none=True)
    async def get_picture_download(picture_uuid: str):
        return logic.get_picture_download(picture_uuid)

    @app.post("/picture", response_model=CCPicture, response_model_exclude_none=True)
    async def create_picture(picture_data: str = Form(...), file: UploadFile = File(...)):
        picture_data = CCPictureData(**json.loads(picture_data))
        return await logic.create_picture(picture_data, file)

    @app.get("/picture/{picture_uuid}", response_model=CCPicture, response_model_exclude_none=True)
    async def get_picture(picture_uuid: str):
        return logic.get_picture(picture_uuid)

    @app.post("/picture/{picture_uuid}", response_model=CCPicture, response_model_exclude_none=True)
    async def update_picture(picture_uuid: str, picture_data: CCPictureData):
        return logic.update_picture(picture_uuid, picture_data)

    @app.patch("/picture/{picture_uuid}", response_model=CCPicture, response_model_exclude_none=True)
    async def patch_picture(picture_uuid: str, picture_data: CCPictureData):
        return logic.patch_picture(picture_uuid, picture_data)

    @app.delete("/picture/{picture_uuid}", response_model=DeleteResponse, response_model_exclude_none=True)
    async def delete_picture(picture_uuid: str):
        success = logic.delete_picture(picture_uuid)

        return DeleteResponse(
            success=success,
            message="Picture deleted" if success else "Picture not found"
        )

    # endregion
