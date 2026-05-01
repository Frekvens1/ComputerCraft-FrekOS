from typing import Optional, Dict, List

from pydantic import BaseModel


# region { Sub types }

class ItemGroup(BaseModel):
    id: str
    displayName: str


class Enchantment(BaseModel):
    name: str
    level: int
    displayName: str


class PotionEffect(BaseModel):
    name: str
    displayName: str
    duration: Optional[int] = None
    potency: Optional[int] = None


# endregion

# region { Storage type }

class StorageItem(BaseModel):
    name: str
    count: int
    nbt: Optional[str] = None


class StorageLookup(StorageItem):
    displayName: str
    maxCount: int
    tags: Dict[str, bool]

    lore: Optional[List[str]] = None
    itemGroups: Optional[List[ItemGroup]] = None

    damage: Optional[int] = None
    maxDamage: Optional[int] = None
    durability: Optional[float] = None
    unbreakable: Optional[bool] = None
    enchantments: Optional[List[Enchantment]] = None

    potionEffects: Optional[List[PotionEffect]] = None

    mapColour: Optional[int] = None
    mapColor: Optional[int] = None


class Storage(BaseModel):
    device_uuid: str
    storage_uuid: str

    slots_used: int
    slots_total: int
    items_total: int
    items: Dict[str, StorageItem]
    lookup: Dict[str, Dict[str, StorageLookup]]
    is_turtle: Optional[bool] = None
    selected_slot: Optional[int] = None

# endregion
