import json
from typing import List

from fastapi import FastAPI, UploadFile
from fastapi.params import Form, File

from modules.common.models import DeleteResponse
from modules.music.models import Playlist, DFPWM, PlaylistData, DFPWMData
from modules.music import logic


def initialize(app: FastAPI):
    # region { Music - Playlist }

    @app.get("/music/playlists", response_model=List[Playlist], response_model_exclude_none=True)
    async def get_all_playlists():
        return logic.get_all_playlists()

    @app.post("/music/playlist", response_model=Playlist, response_model_exclude_none=True)
    async def create_playlist(playlist_data: PlaylistData):
        return logic.create_playlist(playlist_data)

    @app.get("/music/playlist/{playlist_uuid}", response_model=Playlist, response_model_exclude_none=True)
    async def get_playlist(playlist_uuid: str):
        return logic.get_playlist(playlist_uuid)

    @app.post("/music/playlist/{playlist_uuid}", response_model=Playlist, response_model_exclude_none=True)
    async def update_playlist(playlist_uuid: str, playlist_data: PlaylistData):
        return logic.update_playlist(playlist_uuid, playlist_data)

    @app.patch("/music/playlist/{playlist_uuid}", response_model=Playlist, response_model_exclude_none=True)
    async def patch_playlist(playlist_uuid: str, playlist_data: PlaylistData):
        return logic.patch_playlist(playlist_uuid, playlist_data)

    @app.delete("/music/playlist/{playlist_uuid}", response_model=DeleteResponse, response_model_exclude_none=True)
    async def delete_playlist(playlist_uuid: str):
        success = logic.delete_playlist(playlist_uuid)

        return DeleteResponse(
            success=success,
            message="Playlist deleted" if success else "Playlist not found"
        )

    # endregion

    # region { Music - DFPWM }

    @app.get("/music/dfpwm", response_model=List[DFPWM], response_model_exclude_none=True)
    async def get_all_dfpwm():
        return logic.get_all_dfpwm()

    @app.get("/music/dfpwm/{dfpwm_uuid}/stream", response_model=List[DFPWM], response_model_exclude_none=True)
    async def get_dfpwm_stream(dfpwm_uuid: str):
        return logic.get_dfpwm_stream(dfpwm_uuid)

    @app.get("/music/dfpwm/{dfpwm_uuid}/download", response_model=List[DFPWM], response_model_exclude_none=True)
    async def get_dfpwm_download(dfpwm_uuid: str):
        return logic.get_dfpwm_download(dfpwm_uuid)

    @app.post("/music/dfpwm", response_model=DFPWM, response_model_exclude_none=True)
    async def create_dfpwm(dfpwm_data: str = Form(...), file: UploadFile = File(...)):
        dfpwm_data = DFPWMData(**json.loads(dfpwm_data))
        return logic.create_dfpwm(dfpwm_data, file)

    @app.get("/music/dfpwm/{dfpwm_uuid}", response_model=DFPWM, response_model_exclude_none=True)
    async def get_dfpwm(dfpwm_uuid: str):
        return logic.get_dfpwm(dfpwm_uuid)

    @app.post("/music/dfpwm/{dfpwm_uuid}", response_model=DFPWM, response_model_exclude_none=True)
    async def update_dfpwm(dfpwm_uuid: str, dfpwm_data: DFPWMData):
        return logic.update_dfpwm(dfpwm_uuid, dfpwm_data)

    @app.patch("/music/dfpwm/{dfpwm_uuid}", response_model=DFPWM, response_model_exclude_none=True)
    async def patch_dfpwm(dfpwm_uuid: str, dfpwm_data: DFPWMData):
        return logic.patch_dfpwm(dfpwm_uuid, dfpwm_data)

    @app.delete("/music/dfpwm/{dfpwm_uuid}", response_model=DeleteResponse, response_model_exclude_none=True)
    async def delete_dfpwm(dfpwm_uuid: str):
        success = logic.delete_dfpwm(dfpwm_uuid)

        return DeleteResponse(
            success=success,
            message="DFPWM deleted" if success else "DFPWM not found"
        )

    # endregion
