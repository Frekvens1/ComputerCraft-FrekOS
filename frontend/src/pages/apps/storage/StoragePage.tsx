import {Card, CardDescription, CardFooter, CardHeader, CardTitle} from "@/components/ui/card.tsx";
import {useEffect, useState} from "react";
import type {Device} from "@/core/modules/devices/models.ts";
import {DeviceRepository} from "@/core/modules/devices/api.ts";
import {StorageRepository} from "@/core/modules/storage/api.ts";
import {StatusDot} from "@/core/components/StatusDot.tsx";
import type {Storage, StorageItem} from "@/core/modules/storage/models.ts";
import {StorageInventory} from "@/core/modules/storage/components/StorageInventory.tsx";

const deviceRepository = new DeviceRepository();
const storageRepository = new StorageRepository();

interface ClickedStorageItem {
    device_uuid: string;
    storage: Storage;
    slot: number;
    item?: StorageItem;
}

export function StoragePage() {
    const [storages, setStorages] = useState<Storage[]>([]);
    const [devices, setDevices] = useState<Device[]>([]);
    const [onlineDevices, setOnlineDevices] = useState<string[]>([]);
    const [currentSelectedSlot, setCurrentSelectedSlot] = useState<Required<ClickedStorageItem> | null>(null);

    useEffect(() => {
        deviceRepository.getDevicesByType('storage').then((devices) => {
            setDevices(devices);
        });

        deviceRepository.getOnlineDevices().then((devices) => {
            setOnlineDevices(devices);
        });

        storageRepository.getStorages().then((storages) => {
            setStorages(storages);
        });
    }, []);

    async function updateStorage(storageName: string) {
        const updatedStorage = await storageRepository.getStorage(storageName);
        setStorages(prev =>
            prev.map(storage =>
                storage.name === updatedStorage.name ? updatedStorage : storage
            )
        );
    }

    function isDeviceOnline(uuid: string): boolean {
        return onlineDevices.includes(uuid);
    }

    async function sendEvent(device_uuid: string, events: string | string[]): Promise<void> {
        const eventList = Array.isArray(events) ? events : [events]
        await deviceRepository.events.raw(device_uuid, ['frekos_storage', ...eventList])
    }

    async function onItemClick(selectedSlot: Required<ClickedStorageItem>): Promise<void> {
        if (!currentSelectedSlot) {
            setCurrentSelectedSlot(selectedSlot);
        } else {
            await sendEvent(
                currentSelectedSlot.device_uuid,
                [
                    'moveItems',
                    currentSelectedSlot.storage.name,
                    String(currentSelectedSlot.slot),
                    selectedSlot.storage.name,
                    String(selectedSlot.slot),
                    String(currentSelectedSlot.item.count)
                ]
            );

            setCurrentSelectedSlot(null);
            setTimeout(async () => {
                const storageUpdates: Promise<void>[] = [updateStorage(currentSelectedSlot.storage.name)];
                if (currentSelectedSlot.storage.name != selectedSlot.storage.name) {
                    storageUpdates.push(updateStorage(selectedSlot.storage.name));
                }

                await Promise.all(storageUpdates);
            }, 500);
        }
    }

    async function onSlotClick(selectedSlot: ClickedStorageItem): Promise<void> {
        if (!currentSelectedSlot) return;
        await moveItems(currentSelectedSlot, selectedSlot);
    }

    async function moveItems(currentSlot: Required<ClickedStorageItem>, selectedSlot: ClickedStorageItem): Promise<void> {
        await sendEvent(
            currentSlot.device_uuid,
            [
                'moveItems',
                currentSlot.storage.name,
                String(currentSlot.slot),
                selectedSlot.storage.name,
                String(selectedSlot.slot),
                String(currentSlot.item.count)
            ]
        );

        setCurrentSelectedSlot(null);
        setTimeout(async () => {
            const storageUpdates: Promise<void>[] = [updateStorage(currentSlot.storage.name)];
            if (currentSlot.storage.name != selectedSlot.storage.name) {
                storageUpdates.push(updateStorage(selectedSlot.storage.name));
            }

            await Promise.all(storageUpdates);
        }, 500);
    }

    function getSelectedSlot(device_uuid: string, storage_name: string): number {
        if (!currentSelectedSlot) return -1;
        if (currentSelectedSlot.device_uuid !== device_uuid) return -1;
        if (currentSelectedSlot.storage.name !== storage_name) return -1;
        return currentSelectedSlot.slot;
    }

    return (
        <div
            className="flex flex-col gap-4 px-4 *:data-[slot=card]:bg-gradient-to-t *:data-[slot=card]:from-primary/5 *:data-[slot=card]:to-card *:data-[slot=card]:shadow-xs lg:px-6 dark:*:data-[slot=card]:bg-card">
            {
                devices.map((device) => {
                    const id = device.device_uuid;
                    const deviceStorages = storages.map((storage) => storage.device_uuid == id);

                    return (
                        <Card key={id} className="@container/card">
                            <CardHeader>
                                <div className="w-full flex flex-row items-center gap-2">
                                    <StatusDot
                                        status={isDeviceOnline(device.device_uuid) ? 'online' : 'offline'}/>
                                    <CardTitle className="text-xl font-semibold">{device.name}</CardTitle>
                                </div>
                                <CardDescription>{device.description}</CardDescription>
                            </CardHeader>
                            <CardFooter className="flex-col items-start gap-1.5 text-sm">
                                <div className="flex flex-col items-center justify-center gap-4">

                                    <div className="flex flex-col gap-2 items-center">
                                        <p>Inventories: {deviceStorages.length}</p>

                                        <div
                                            className="grid grid-cols-1 gap-4 @xl/main:grid-cols-2 @5xl/main:grid-cols-4">
                                            {
                                                storages.map((storage: Storage) => {
                                                    return (
                                                        <div className='flex flex-col'>
                                                            <p>Name: {storage.name}</p>
                                                            <p>Items total: {storage.items_total}</p>
                                                            <p>Slots total: {storage.slots_total}</p>
                                                            <p>Slots used: {storage.slots_used}</p>
                                                            <p>Slots
                                                                free: {storage.slots_total - storage.slots_used}</p>

                                                            <StorageInventory
                                                                storage={storage}
                                                                selectedSlot={getSelectedSlot(id, storage.name)}
                                                                onSlotEventClick={(slot: number) =>
                                                                    onSlotClick({
                                                                        device_uuid: id,
                                                                        storage: storage,
                                                                        slot: slot,
                                                                    })
                                                                }
                                                                onItemEventClick={(item: StorageItem, slot: number) =>
                                                                    onItemClick({
                                                                        device_uuid: id,
                                                                        storage: storage,
                                                                        item: item,
                                                                        slot: slot,
                                                                    })}/>
                                                        </div>
                                                    )
                                                })
                                            }
                                        </div>

                                    </div>

                                </div>
                            </CardFooter>
                        </Card>
                    )
                })
            }
        </div>
    )
}
