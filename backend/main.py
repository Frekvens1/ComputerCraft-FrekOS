from typing import Optional, Dict, List

from fastapi import FastAPI
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
from starlette.websockets import WebSocket, WebSocketDisconnect

from libraries import mongo_lib

from modules.devices.api import initialize as devices_api

# pip install 'uvicorn[standard]'
teleport_websocket: Optional[WebSocket] = None
devices: Dict[str, WebSocket] = {}

app = FastAPI()
mongo_lib.initialize()

app.mount('/computercraft', StaticFiles(directory='computercraft'), name='computercraft')


@app.get('/')
async def root():
    return {'message': 'Hello ComputerCraft!'}


@app.get('/frekos/install')
async def install():
    return FileResponse('frekos-install.lua', media_type='text/plain')


@app.get('/frekos/update')
async def update():
    return FileResponse('frekos-install.lua', media_type='text/plain')


@app.get('/teleport/{device_uuid}')
async def teleport(device_uuid: str):
    device = devices[device_uuid]
    if device:
        await device.send_text('Teleport!')
        return {'message': 'Teleport requested!'}
    return {'message': 'No teleport active!'}

@app.get('/device-online/{device_uuid}')
async def device_online(device_uuid: str) -> bool:
    return device_uuid in devices

@app.get('/devices/online')
async def devices_online() -> List[str]:
    return list(devices.keys())


@app.websocket("/device/{device_uuid}")
async def device_websocket(device_uuid: str, websocket: WebSocket):
    global devices

    await websocket.accept()
    devices[device_uuid] = websocket
    print(f"Device connected: {device_uuid}")
    try:
        while True:
            msg = await websocket.receive_text()
            print(f"{device_uuid}: ", msg)
    except WebSocketDisconnect:
        devices.pop(device_uuid, None)
        print(f"Device disconnected: {device_uuid}")

devices_api(app)
