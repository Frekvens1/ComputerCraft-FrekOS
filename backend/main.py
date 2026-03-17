from fastapi import FastAPI
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles

from libraries import mongo_lib

from modules.devices.api import initialize as devices_api

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

devices_api(app)
