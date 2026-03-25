from typing import List

from fastapi import FastAPI
from starlette.websockets import WebSocket, WebSocketDisconnect

from modules.devices import logic
from modules.devices.models import (
    DeleteDeviceResponse, DeviceData, Device,
)


def initialize(app: FastAPI):
    @app.get("/devices", response_model=List[Device])
    async def get_devices():
        return logic.get_devices()

    @app.get("/devices/type/{device_type}", response_model=List[Device])
    async def get_devices_by_type(device_type: str):
        return logic.get_devices_by_type(device_type)

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

    # Experimental functions

    @app.get('/device/{device_uuid}/online')
    async def device_online(device_uuid: str) -> bool:
        return device_uuid in logic.devices

    @app.get('/devices/online')
    async def devices_online() -> List[str]:
        return list(logic.devices.keys())

    @app.websocket("/device/{device_uuid}")
    async def device_websocket(device_uuid: str, websocket: WebSocket):
        await websocket.accept()
        logic.devices[device_uuid] = websocket
        print(f"Device connected: {device_uuid}")
        try:
            while True:
                msg = await websocket.receive_text()
                print(f"{device_uuid}: ", msg)
        except WebSocketDisconnect:
            logic.devices.pop(device_uuid, None)
            print(f"Device disconnected: {device_uuid}")

    @app.get('/device/{device_uuid}/events/teleport')
    async def teleport(device_uuid: str):
        if device_uuid in logic.devices:
            device = logic.devices[device_uuid]
            await device.send_json([
                "frekos_teleport",
            ])
            return {'message': 'Teleport requested!'}
        return {'message': 'No teleport active!'}
