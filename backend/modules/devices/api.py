import asyncio
import json
from typing import List

from fastapi import FastAPI, Body, HTTPException
from starlette.websockets import WebSocket, WebSocketDisconnect

from modules.common.models import DeleteResponse
from modules.devices import logic
from modules.devices.models import (
    DeviceData, Device, DeviceState, DeviceStateData, DeviceType,
)


def initialize(app: FastAPI):
    @app.get("/devices", response_model=List[Device], response_model_exclude_none=True)
    async def get_devices():
        return logic.get_devices()

    @app.get("/devices/module/{device_module}", response_model=List[Device], response_model_exclude_none=True)
    async def get_devices_by_module(device_module: str):
        return logic.get_devices_by_module(device_module)

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

    @app.delete("/device/{device_uuid}", response_model=DeleteResponse, response_model_exclude_none=True)
    async def delete_device(device_uuid: str):
        success = await logic.delete_device(device_uuid)

        return DeleteResponse(
            success=success,
            message="Device deleted" if success else "Device not found"
        )

    # region { device state }

    @app.get("/devices/type/{device_type}", response_model=List[Device], response_model_exclude_none=True)
    async def get_devices_by_type(device_type: DeviceType):
        return logic.get_devices_by_type(device_type)

    @app.get("/device/{device_uuid}/state", response_model=DeviceState, response_model_exclude_none=True)
    async def get_device(device_uuid: str):
        device_state = logic.get_device_state(device_uuid)
        device_state.is_online = device_uuid in logic.devices
        return device_state

    @app.post("/device/{device_uuid}/state", response_model=DeviceState, response_model_exclude_none=True)
    async def update_device(device_uuid: str, device_state: DeviceStateData):
        return logic.update_device_state(device_uuid, device_state)

    @app.patch("/device/{device_uuid}/state", response_model=DeviceState, response_model_exclude_none=True)
    async def patch_device(device_uuid: str, device_state: DeviceStateData):
        return logic.patch_device_state(device_uuid, device_state)

    @app.delete("/device/{device_uuid}/state", response_model=DeleteResponse, response_model_exclude_none=True)
    async def delete_device(device_uuid: str):
        success = logic.delete_device_state(device_uuid)

        return DeleteResponse(
            success=success,
            message="Device deleted" if success else "Device not found"
        )

    # endregion

    # Experimental functions

    @app.get('/device/{device_uuid}/online')
    async def device_online(device_uuid: str) -> bool:
        return device_uuid in logic.devices

    @app.get('/devices/online')
    async def devices_online() -> List[str]:
        return list(logic.devices.keys())

    @app.websocket("/device/{device_uuid}")
    async def device_websocket(device_uuid: str, websocket: WebSocket):
        device = logic.get_device(device_uuid)
        await websocket.accept()

        if device is None:
            print(f"Unknown device connected: ({device_uuid})")
            try:
                await asyncio.wait_for(websocket.receive_text(), timeout=3)
                await websocket.send_json(["frekos_wipe_device"])
            except asyncio.TimeoutError:
                print(f"Unknown device timed out: ({device_uuid})")
            except WebSocketDisconnect:
                print(f"Unknown device disconnected early: ({device_uuid})")
            finally:
                await websocket.close()

            return

        logic.devices[device_uuid] = websocket
        print(f"Device connected: {device.name} ({device_uuid})")
        try:
            while True:
                msg = await websocket.receive_text()
                try:
                    parsed = json.loads(msg)
                    pretty = json.dumps(parsed, indent=4, ensure_ascii=False)
                    print(f"{device.name} ({device_uuid}) (JSON):\n{pretty}")
                except json.JSONDecodeError:
                    print(f"{device.name} ({device_uuid}): {msg}")
        except WebSocketDisconnect:
            logic.devices.pop(device_uuid, None)
            print(f"Device disconnected: {device.name} ({device_uuid})")

    @app.post("/device/{device_uuid}/event")
    async def device_event(device_uuid: str, event=Body(...)):
        if device_uuid not in logic.devices:
            raise HTTPException(status_code=404, detail="Device not online")

        if not isinstance(event, list):
            raise HTTPException(status_code=400, detail="Event must be a list or nested list")

        await logic.send_device_event(device_uuid, event)

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
