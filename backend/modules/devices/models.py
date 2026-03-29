from enum import Enum
from typing import List, Optional

from bson import ObjectId
from pydantic import BaseModel, Field, field_validator


class DeviceType(Enum):
    COMPUTER = 'computer'
    TURTLE = 'turtle'
    POCKET = 'pocket'
    COMMAND = 'command'


class Position(BaseModel):
    x: int
    y: int
    z: int


class Peripheral(BaseModel):
    name: str
    types: List[str]
    methods: List[str]


class DeviceState(BaseModel):
    is_online: bool

    id: str
    type: DeviceType
    has_color: bool
    connected_peripherals: dict

    current_volume: Optional[int] = None
    fuel_amount: Optional[int] = None
    fuel_amount_max: Optional[int] = None
    gps_position: Optional[Position] = None


# region { Device model } // TODO: #27 - More device settings

class DeviceData(BaseModel):
    name: str
    description: str
    type: str

#    use_gps: bool
#    password: str
#    use_lockscreen: bool

 #   custom_startup_script: str
 #   device_position: Optional[Position] = None
 #   device_state: Optional[DeviceState] = None


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
    message: Optional[str] = None

# endregion
