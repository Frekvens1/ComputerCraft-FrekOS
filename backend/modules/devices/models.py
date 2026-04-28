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


class DeviceStateData(BaseModel):
    type: DeviceType
    has_color: bool
    connected_peripherals: Optional[List[Peripheral]] = None

    current_volume: Optional[int] = None
    fuel_amount: Optional[int] = None
    fuel_amount_max: Optional[int] = None
    gps_position: Optional[Position] = None

    class Config:
        use_enum_values = True


# region { Device model }

class DeviceData(BaseModel):
    name: str
    description: str
    modules: Optional[List[str]] = None

    use_lockscreen: Optional[bool] = None
    password: Optional[str] = None
    password_salt: Optional[str] = None

    custom_startup_script: Optional[str] = None


class Device(DeviceData):
    device_state: Optional[DeviceStateData] = None
    device_uuid: str


class DeviceState(DeviceStateData):
    is_online: Optional[bool] = None
    device_uuid: str


class DeviceBackend(Device):
    id: str = Field(alias='_id')

    @field_validator('id', mode='before')
    def convert(v):
        return str(v) if isinstance(v, ObjectId) else v


class DeviceStateBackend(DeviceState):
    id: str = Field(alias='_id')

    @field_validator('id', mode='before')
    def convert(v):
        return str(v) if isinstance(v, ObjectId) else v

# endregion
