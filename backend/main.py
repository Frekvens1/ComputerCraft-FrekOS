from fastapi import FastAPI
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles

from libraries import mongo_lib

from modules.devices.api import initialize as devices_api
from modules.devices import logic as devices_logic

# pip install 'uvicorn[standard]'

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


@app.get('/device/{device_uuid}/event')
async def device_event(device_uuid: str):
    if device_uuid in devices_logic.devices:
        device = devices_logic.devices[device_uuid]
        await device.send_json([
            ["char", "u"],
            ["char", "p"],
            ["char", "d"],
            ["char", "a"],
            ["char", "t"],
            ["char", "e"],
            ["key", 335, False],  # enter key
        ])
        return {'message': 'Event sent!'}
    return {'message': 'Device not online!'}


devices_api(app)
