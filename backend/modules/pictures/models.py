from pydantic import BaseModel


# region { Picture data }

class CCPictureData(BaseModel):
    name: str

# endregion

# region { Picture types }

class CCPicture(CCPictureData):
    picture_uuid: str
    file_uuid: str
    filename: str
    size: int

# endregion
