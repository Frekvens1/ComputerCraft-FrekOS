// region { Sub types }

export interface ItemGroup {
    id: string;
    displayName: string;
}


export interface Enchantment {
    name: string;
    level: number;
    displayName: string;
}


export interface PotionEffect {
    name: string;
    displayName: string;
    duration?: number;
    potency?: number;
}


// endregion

// region { Storage type }

export interface StorageItem {
    name: string;
    count: number;
    nbt?: string;
}


export interface StorageLookup extends StorageItem {
    displayName: string;
    maxCount: number;
    tags: {[key: string]: boolean};

    lore?: string[];
    itemGroups?: ItemGroup[];

    damage?: number;
    maxDamage?: number;
    durability?: number;
    unbreakable?: boolean;
    enchantments?: Enchantment[];

    potionEffects?: PotionEffect[];

    mapColour?: number;
    mapColor?: number;
}


export interface Storage {
    device_uuid: string;
    storage_uuid: string;

    slots_used: number;
    slots_total: number;
    items_total: number;
    items: {[slot: string]: StorageItem};
    lookup: {[itemId: string]: {[hash: string]: StorageLookup}};
    is_turtle?: boolean;
    selected_slot?: number;
}

// endregion
