from asyncio import Event
from typing import List, Optional, Dict

from starlette.websockets import WebSocket

from libraries import mongo_lib
from libraries import security_lib
from modules.devices.models import Device, DeviceBackend, DeviceData, DeviceStateBackend, DeviceStateData, DeviceType

devices: Dict[str, WebSocket] = {}


def device_collection():
    return mongo_lib.mongo_collection(
        mongo_lib.MongoCollection(
            database='frekos',
            collection='devices'
        ))


def device_state_collection():
    return mongo_lib.mongo_collection(
        mongo_lib.MongoCollection(
            database='frekos',
            collection='device_states'
        ))


# region { Devices - Database }

def get_devices() -> List[DeviceBackend]:
    docs = list(device_collection().find({}))
    return [DeviceBackend(**doc) for doc in docs]


def get_devices_by_module(device_module: str) -> List[DeviceBackend]:
    docs = list(device_collection().find({'modules': device_module}))
    return [DeviceBackend(**doc) for doc in docs]


def device_exists(device_uuid: str) -> bool:
    return device_collection().find_one({'device_uuid': device_uuid}) is not None


def get_device(device_uuid: str) -> Optional[DeviceBackend]:
    doc = device_collection().find_one({'device_uuid': device_uuid})
    return DeviceBackend(**doc) if doc else None


def create_device(device_data: DeviceData) -> DeviceBackend:
    device = Device(
        device_uuid=str(security_lib.generate_uuid()),
        **device_data.model_dump(exclude_none=True),
    )
    result = device_collection().insert_one(device.model_dump(exclude_none=True))

    created = device_collection().find_one({"_id": result.inserted_id})
    return DeviceBackend(**created)


def update_device(device_uuid: str, device: Device) -> DeviceBackend:
    if device.password:
        device.password_salt = security_lib.salt()
        device.password = security_lib.sha256(device.password_salt + device.password)

    device_collection().update_one(
        {'device_uuid': device_uuid},
        {'$set': device.model_dump(exclude_none=True)}
    )
    updated = device_collection().find_one({'device_uuid': device.device_uuid})
    return DeviceBackend(**updated) if updated else None


def patch_device(device_uuid: str, device: Device) -> DeviceBackend:
    if device.password:
        device.password_salt = security_lib.salt()
        device.password = security_lib.sha256(device.password_salt + device.password)

    device_collection().update_one(
        {'device_uuid': device_uuid},
        {'$set': device.model_dump(exclude_none=True)}
    )
    updated = device_collection().find_one({'device_uuid': device.device_uuid})
    return DeviceBackend(**updated) if updated else None


async def delete_device(device_uuid: str) -> bool:
    delete_device_state(device_uuid)
    result = device_collection().delete_one({'device_uuid': device_uuid})
    await send_device_event(device_uuid, ['frekos_wipe_device'])
    await close_device_websocket(device_uuid)
    return result.deleted_count > 0


# endregion

# region { Device state - Database }

def get_device_states() -> List[DeviceStateBackend]:
    docs = list(device_state_collection().find({}))
    return [DeviceStateBackend(**doc) for doc in docs]

def get_devices_by_type(device_type: DeviceType) -> List[DeviceBackend]:
    state_docs = list(device_state_collection().find({'type': device_type.value}))
    uuids = [doc['device_uuid'] for doc in state_docs]
    docs = list(device_collection().find({'device_uuid': {'$in': uuids}}))
    return [DeviceBackend(**doc) for doc in docs]


def get_device_state(device_uuid: str) -> Optional[DeviceStateBackend]:
    doc = device_state_collection().find_one({'device_uuid': device_uuid})
    return DeviceStateBackend(**doc) if doc else None


def update_device_state(device_uuid: str, device_state: DeviceStateData) -> DeviceStateBackend | None:
    if not device_exists(device_uuid):
        return None

    device_state_collection().update_one(
        {'device_uuid': device_uuid},
        {'$set': device_state.model_dump(exclude_none=True)},
        upsert=True
    )
    updated = device_state_collection().find_one({'device_uuid': device_uuid})
    return DeviceStateBackend(**updated) if updated else None


def patch_device_state(device_uuid: str, device_state: DeviceStateData) -> DeviceStateBackend | None:
    if not device_exists(device_uuid):
        return None

    device_state_collection().update_one(
        {'device_uuid': device_uuid},
        {'$set': device_state.model_dump(exclude_none=True)}
    )
    updated = device_state_collection().find_one({'device_uuid': device_uuid})
    return DeviceStateBackend(**updated) if updated else None


def delete_device_state(device_uuid: str) -> bool:
    result = device_state_collection().delete_one({'device_uuid': device_uuid})
    return result.deleted_count > 0


# endregion

async def send_device_event(device_uuid: str, event) -> bool:
    if not device_uuid in devices:
        return False

    device = devices[device_uuid]
    await device.send_json(event)
    return True


async def close_device_websocket(device_uuid: str) -> bool:
    if not device_uuid in devices:
        return False

    device = devices[device_uuid]
    await device.close()
    return True
