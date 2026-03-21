from typing import Optional

from fastapi import FastAPI
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
from starlette.websockets import WebSocket

from libraries import mongo_lib

from modules.devices.api import initialize as devices_api

# pip install 'uvicorn[standard]'
teleport_websocket: Optional[WebSocket] = None

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


@app.get('/teleport')
async def teleport():
    if teleport_websocket:
        await teleport_websocket.send_text('Teleport!')
        return {'message': 'Teleport requested!'}
    return {'message': 'No teleport active!'}


@app.websocket("/teleport")
async def websocket_endpoint(websocket: WebSocket):
    global teleport_websocket

    await websocket.accept()
    teleport_websocket = websocket
    while True:
        msg = await websocket.receive_text()
        print("Received:", msg)


devices_api(app)
