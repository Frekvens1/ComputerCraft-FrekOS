from fastapi import FastAPI
from modules.devices import logic
from modules.devices.models import (
    DeviceRequest,
    DevicesResponse,
    DeviceResponse,
    DeleteDeviceResponse, DeviceData,
)


def initialize(app: FastAPI):
    @app.get("/devices", response_model=DevicesResponse)
    async def get_devices():
        return DevicesResponse(devices=logic.get_devices())

    @app.get("/device/{device_uuid}", response_model=DeviceResponse)
    async def get_device(device_uuid: str):
        device = logic.get_device(device_uuid)
        return DeviceResponse(device=device)

    @app.post("/device", response_model=DeviceResponse)
    async def create_device(device_data: DeviceData):
        device = logic.create_device(device_data)
        return DeviceResponse(device=device)

    @app.put("/device", response_model=DeviceResponse)
    async def update_device(request: DeviceRequest):
        updated = logic.update_device(request.device)
        return DeviceResponse(device=updated)

    @app.patch("/device", response_model=DeviceResponse)
    async def patch_device(request: DeviceRequest):
        updated = logic.patch_device(request.device)
        return DeviceResponse(device=updated)

    @app.delete("/device/{device_uuid}", response_model=DeleteDeviceResponse)
    async def delete_device(device_uuid: str):
        success = logic.delete_device(device_uuid)

        return DeleteDeviceResponse(
            success=success,
            message="Device deleted" if success else "Device not found"
        )
