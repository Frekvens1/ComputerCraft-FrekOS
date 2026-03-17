from typing import List

from fastapi import FastAPI
from modules.devices import logic
from modules.devices.models import (
    DeleteDeviceResponse, DeviceData, Device,
)


def initialize(app: FastAPI):
    @app.get("/devices", response_model=List[Device])
    async def get_devices():
        return logic.get_devices()

    @app.get("/device/{device_uuid}", response_model=Device)
    async def get_device(device_uuid: str):
        return logic.get_device(device_uuid)

    @app.post("/device", response_model=Device)
    async def create_device(device_data: DeviceData):
        return logic.create_device(device_data)

    @app.put("/device", response_model=Device)
    async def update_device(device: Device):
        return logic.update_device(device)

    @app.patch("/device", response_model=Device)
    async def patch_device(device: Device):
        return logic.patch_device(device)

    @app.delete("/device/{device_uuid}", response_model=DeleteDeviceResponse)
    async def delete_device(device_uuid: str):
        success = logic.delete_device(device_uuid)

        return DeleteDeviceResponse(
            success=success,
            message="Device deleted" if success else "Device not found"
        )
