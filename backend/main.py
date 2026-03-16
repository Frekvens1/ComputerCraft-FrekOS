from fastapi import FastAPI
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles

app = FastAPI()

app.mount("/frekos", StaticFiles(directory="frekos"), name="frekos")

@app.get("/")
async def root():
    return {"message": "Hello ComputerCraft!"}


@app.get("/install")
async def install():
    return FileResponse("frekos/update.lua", media_type="text/plain")
