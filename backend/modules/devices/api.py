import json
from typing import List

from fastapi import FastAPI, Body, HTTPException
from starlette.websockets import WebSocket, WebSocketDisconnect

from modules.devices import logic
from modules.devices.models import (
    DeleteDeviceResponse, DeviceData, Device,
)


def initialize(app: FastAPI):
    @app.get("/devices", response_model=List[Device], response_model_exclude_none=True)
    async def get_devices():
        return logic.get_devices()

    @app.get("/devices/type/{device_type}", response_model=List[Device], response_model_exclude_none=True)
    async def get_devices_by_type(device_type: str):
        return logic.get_devices_by_type(device_type)

    @app.post("/device", response_model=Device, response_model_exclude_none=True)
    async def create_device(device_data: DeviceData):
        return logic.create_device(device_data)

    @app.get("/device/{device_uuid}", response_model=Device, response_model_exclude_none=True)
    async def get_device(device_uuid: str):
        return logic.get_device(device_uuid)

    @app.post("/device/{device_uuid}", response_model=Device, response_model_exclude_none=True)
    async def update_device(device_uuid: str, device: Device):
        return logic.update_device(device_uuid, device)

    @app.patch("/device/{device_uuid}", response_model=Device, response_model_exclude_none=True)
    async def patch_device(device_uuid: str, device: Device):
        return logic.patch_device(device_uuid, device)

    @app.delete("/device/{device_uuid}", response_model=DeleteDeviceResponse, response_model_exclude_none=True)
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
                try:
                    parsed = json.loads(msg)
                    pretty = json.dumps(parsed, indent=4, ensure_ascii=False)
                    print(f"{device_uuid} (JSON):\n{pretty}")
                except json.JSONDecodeError:
                    print(f"{device_uuid}: {msg}")
        except WebSocketDisconnect:
            logic.devices.pop(device_uuid, None)
            print(f"Device disconnected: {device_uuid}")

    @app.post("/device/{device_uuid}/event")
    async def device_event(device_uuid: str, event=Body(...)):
        if device_uuid not in logic.devices:
            raise HTTPException(status_code=404, detail="Device not online")

        if not isinstance(event, list):
            raise HTTPException(status_code=400, detail="Event must be a list or nested list")

        device = logic.devices[device_uuid]
        await device.send_json(event)

        return {"message": "Event sent!"}

    @app.get('/device/{device_uuid}/events/teleport')
    async def teleport(device_uuid: str):
        if device_uuid in logic.devices:
            device = logic.devices[device_uuid]
            await device.send_json([
                "frekos_teleport",
            ])
            return {'message': 'Teleport requested!'}
        return {'message': 'No teleport active!'}
