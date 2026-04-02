from typing import List, Optional

from libraries import mongo_lib
from modules.storage.models import Storage


def storage_collection():
    return mongo_lib.mongo_collection(
        mongo_lib.MongoCollection(
            database='frekos',
            collection='storages'
        ))


# region { Devices - Database }

def get_storages() -> List[Storage]:
    docs = list(storage_collection().find({}))
    return [Storage(**doc) for doc in docs]


def get_storages_by_device(device_uuid: str) -> List[Storage]:
    docs = list(storage_collection().find({'device_uuid': device_uuid}))
    return [Storage(**doc) for doc in docs]


def get_storage(storage_uuid: str) -> Optional[Storage]:
    doc = storage_collection().find_one({'storage_uuid': storage_uuid})
    return Storage(**doc) if doc else None


def update_storage(storage_uuid: str, storage: Storage) -> Storage:
    storage_collection().update_one(
        {'storage_uuid': storage_uuid},
        {'$set': storage.model_dump(exclude_none=True)},
        upsert=True,
    )
    updated = storage_collection().find_one({'storage_uuid': storage.storage_uuid})
    return Storage(**updated) if updated else None


def patch_storage(storage_uuid: str, storage: Storage) -> Storage:
    storage_collection().update_one(
        {'storage_uuid': storage_uuid},
        {'$set': storage.model_dump(exclude_none=True)}
    )
    updated = storage_collection().find_one({'storage_uuid': storage.storage_uuid})
    return Storage(**updated) if updated else None


def delete_storage(storage_uuid: str) -> bool:
    result = storage_collection().delete_one({'storage_uuid': storage_uuid})
    return result.deleted_count > 0

# endregion
