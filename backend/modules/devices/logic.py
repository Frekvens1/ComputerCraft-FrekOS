from typing import List, Optional

from libraries import mongo_lib
from libraries import security_lib
from modules.devices.models import Device, DeviceBackend, DeviceData


def device_collection():
    return mongo_lib.mongo_collection(
        mongo_lib.MongoCollection(
            database='frekos',
            collection='devices'
        ))


# region { Devices - Database }

def get_devices() -> List[DeviceBackend]:
    docs = list(device_collection().find({}))
    return [DeviceBackend(**doc) for doc in docs]


def get_device(device_uuid: str) -> Optional[DeviceBackend]:
    doc = device_collection().find_one({'device_uuid': device_uuid})
    return DeviceBackend(**doc) if doc else None


def create_device(device_data: DeviceData) -> DeviceBackend:
    device = Device(
        device_uuid=str(security_lib.generate_uuid()),
        **device_data.model_dump(),
    )
    result = device_collection().insert_one(device.model_dump())

    created = device_collection().find_one({"_id": result.inserted_id})
    return DeviceBackend(**created)


def update_device(device: Device) -> DeviceBackend:
    device_collection().update_one(
        {'device_uuid': device.device_uuid},
        {'$set': device.model_dump()}
    )
    updated = device_collection().find_one({'device_uuid': device.device_uuid})
    return DeviceBackend(**updated) if updated else None


def patch_device(device: Device) -> DeviceBackend:
    device_collection().update_one(
        {'device_uuid': device.device_uuid},
        {'$set': device.model_dump()}
    )
    updated = device_collection().find_one({'device_uuid': device.device_uuid})
    return DeviceBackend(**updated) if updated else None


def delete_device(device_uuid: str) -> bool:
    result = device_collection().delete_one({'device_uuid': device_uuid})
    return result.deleted_count > 0

# endregion
