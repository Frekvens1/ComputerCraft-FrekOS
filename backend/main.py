import logging

from fastapi import FastAPI
from fastapi.exceptions import RequestValidationError
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
from starlette.requests import Request
from starlette.responses import JSONResponse

from libraries import mongo_lib, s3_lib

from modules.devices.api import initialize as devices_api
from modules.storage.api import initialize as storage_api
from modules.music.api import initialize as music_api
from modules.pictures.api import initialize as pictures_api

# pip install 'uvicorn[standard]'
# pip install python-multipart

app = FastAPI()
mongo_lib.initialize()
s3_lib.initialize()

app.mount('/computercraft', StaticFiles(directory='computercraft'), name='computercraft')
logger = logging.getLogger("uvicorn.error")


@app.get('/')
async def root():
    return {'message': 'Hello ComputerCraft!'}


@app.get('/frekos/install')
async def install():
    return FileResponse('frekos-install.lua', media_type='text/plain')


@app.get('/frekos/update')
async def update():
    return FileResponse('frekos-install.lua', media_type='text/plain')


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    body = await request.body()

    logger.error("422 Unprocessable Entity")
    logger.error(f"URL: {request.url}")
    logger.error(f"Method: {request.method}")
    logger.error(f"Headers: {dict(request.headers)}")
    logger.error(f"Body: {body.decode('utf-8', errors='ignore')}")
    logger.error(f"Validation errors: {exc.errors()}")

    return JSONResponse(
        status_code=422,
        content={
            "detail": exc.errors(),
            "body": body.decode("utf-8", errors="ignore")
        },
    )


devices_api(app)
storage_api(app)
music_api(app)
pictures_api(app)
