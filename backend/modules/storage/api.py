from typing import List

from fastapi import FastAPI

from modules.common.models import DeleteResponse
from modules.storage import logic
from modules.storage.models import Storage


def initialize(app: FastAPI):
    @app.get("/storages", response_model=List[Storage], response_model_exclude_none=True)
    async def get_storages():
        return logic.get_storages()

    @app.get("/storages/device/{device_uuid}", response_model=List[Storage], response_model_exclude_none=True)
    async def get_storages_by_device(device_uuid: str):
        return logic.get_storages_by_device(device_uuid)

    @app.get("/storage/{inventory_name}", response_model=Storage, response_model_exclude_none=True)
    async def get_storage(inventory_name: str):
        return logic.get_storage(inventory_name)

    @app.post("/storage/{inventory_name}", response_model=Storage, response_model_exclude_none=True)
    async def update_storage(inventory_name: str, storage: Storage):
        return logic.update_storage(inventory_name, storage)

    @app.patch("/storage/{inventory_name}", response_model=Storage, response_model_exclude_none=True)
    async def patch_storage(inventory_name: str, storage: Storage):
        return logic.patch_storage(inventory_name, storage)

    @app.delete("/storage/{inventory_name}", response_model=DeleteResponse, response_model_exclude_none=True)
    async def delete_storage(inventory_name: str):
        success = logic.delete_storage(inventory_name)

        return DeleteResponse(
            success=success,
            message="Storage deleted" if success else "Storage not found"
        )
