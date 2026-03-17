from fastapi import FastAPI
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles

app = FastAPI()

app.mount('/computercraft', StaticFiles(directory='computercraft'), name='computercraft')

@app.get('/')
async def root():
    return {'message': 'Hello ComputerCraft!'}


@app.get('/install')
async def install():
    return FileResponse('computercraft/frekos/apps/update.lua', media_type='text/plain')
