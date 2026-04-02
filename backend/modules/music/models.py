from typing import Optional, List

from pydantic import BaseModel


# region { Music data }

class PlaylistData(BaseModel):
    name: str
    dfpwm: Optional[List[str]] # dfpwm_uuid

class DFPWMData(BaseModel):
    name: str
    seconds: Optional[int] = None

# endregion

# region { Music types }

class Playlist(PlaylistData):
    playlist_uuid: str

class DFPWM(DFPWMData):
    dfpwm_uuid: str
    file_uuid: str
    filename: str
    size: int

# endregion
