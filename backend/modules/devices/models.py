from typing import List

from bson import ObjectId
from pydantic import BaseModel, Field, field_validator


# region { Device model }

class DeviceData(BaseModel):
    name: str
    description: str


class Device(DeviceData):
    device_uuid: str


class DeviceBackend(Device):
    id: str = Field(alias='_id')

    @field_validator('id', mode='before')
    def convert(v):
        return str(v) if isinstance(v, ObjectId) else v


# endregion

# region { API responses }

class DeleteDeviceResponse(BaseModel):
    success: bool
    message: str | None = None

# endregion
