import {Button} from "@/components/ui/button.tsx";
import {Card, CardDescription, CardFooter, CardHeader, CardTitle} from "@/components/ui/card.tsx";
import {createRef, type RefObject, useEffect, useRef, useState} from "react";
import type {Device} from "@/core/modules/devices/models.ts";
import {DeviceRepository} from "@/core/modules/devices/api.ts";
import {Field, FieldLabel} from "@/components/ui/field.tsx";
import {Input} from "@/components/ui/input.tsx";
import type {Storage, StorageItem} from "@/core/modules/storage/models.ts";
import {StorageRepository} from "@/core/modules/storage/api.ts";
import {StorageInventory} from "@/core/modules/storage/components/StorageInventory.tsx";
import type {ClickedStorageItem} from "@/pages/apps/storage/StoragePage.tsx";
import {ButtonGroup} from "@/components/ui/button-group.tsx";
import {
    IconArrowBigDown,
    IconArrowBigUp,
    IconEscalatorDown,
    IconEscalatorUp,
    IconHammer,
    IconPick,
    IconRotate2,
    IconRotateClockwise2, IconStackPop, IconStackPush
} from "@tabler/icons-react";

const deviceRepository = new DeviceRepository();
const storageRepository = new StorageRepository();

export function MinerPage() {
    const [devices, setDevices] = useState<Device[]>([]);
    const [storages, setStorages] = useState<Storage[]>([]);
    const [onlineDevices, setOnlineDevices] = useState<string[]>([]);
    const [currentSelectedSlot, setCurrentSelectedSlot] = useState<Required<ClickedStorageItem> | null>(null);

    const buildWidthRefs = useRef<Record<string, RefObject<HTMLInputElement | null>>>({});
    const buildLengthRefs = useRef<Record<string, RefObject<HTMLInputElement | null>>>({});

    const mineWidthRefs = useRef<Record<string, RefObject<HTMLInputElement | null>>>({});
    const mineLengthRefs = useRef<Record<string, RefObject<HTMLInputElement | null>>>({});
    const mineHeightRefs = useRef<Record<string, RefObject<HTMLInputElement | null>>>({});


    useEffect(() => {
        deviceRepository.getDevicesByType('turtle').then((devices) => {
            setDevices(devices);
        });

        deviceRepository.getOnlineDevices().then((devices) => {
            setOnlineDevices(devices);
        });

        storageRepository.getStorages().then((storages) => {
            setStorages(storages);
        });
    }, []);

    function isDeviceOnline(uuid: string): boolean {
        return onlineDevices.includes(uuid);
    }

    async function sendTurtleEvent(device_uuid: string, events: string | string[], update?: boolean): Promise<void> {
        const eventList = Array.isArray(events) ? events : [events]
        await deviceRepository.events.raw(device_uuid, ['frekos_turtle', ...eventList])
        if (update) setTimeout(async () => updateStorage(device_uuid), 500);
    }

    async function sendStorageEvent(device_uuid: string, events: string | string[]): Promise<void> {
        const eventList = Array.isArray(events) ? events : [events]
        await deviceRepository.events.raw(device_uuid, ['frekos_storage', ...eventList])
    }

    async function onItemClick(selectedSlot: Required<ClickedStorageItem>): Promise<void> {
        if (!currentSelectedSlot) {
            setCurrentSelectedSlot(selectedSlot);
        } else {
            await sendStorageEvent(
                currentSelectedSlot.device_uuid,
                [
                    'moveItems',
                    currentSelectedSlot.storage.storage_uuid,
                    String(currentSelectedSlot.slot),
                    selectedSlot.storage.storage_uuid,
                    String(selectedSlot.slot),
                    String(currentSelectedSlot.item.count)
                ]
            );

            setCurrentSelectedSlot(null);
            setTimeout(async () => {
                const storageUpdates: Promise<void>[] = [updateStorage(currentSelectedSlot.storage.storage_uuid)];
                if (currentSelectedSlot.storage.storage_uuid != selectedSlot.storage.storage_uuid) {
                    storageUpdates.push(updateStorage(selectedSlot.storage.storage_uuid));
                }

                await Promise.all(storageUpdates);
            }, 500);
        }
    }

    async function onSlotDoubleClick(selectedSlot: ClickedStorageItem): Promise<void> {
        await sendTurtleEvent(selectedSlot.device_uuid, ['select', String(selectedSlot.slot)]);
        setTimeout(async () => updateStorage(selectedSlot.storage.storage_uuid), 250);
    }

    async function onSlotClick(selectedSlot: ClickedStorageItem): Promise<void> {
        if (!currentSelectedSlot) return;
        await moveItems(currentSelectedSlot, selectedSlot);
    }

    async function moveItems(currentSlot: Required<ClickedStorageItem>, selectedSlot: ClickedStorageItem): Promise<void> {
        if (currentSlot.storage.is_turtle != selectedSlot.storage.is_turtle) {
            setCurrentSelectedSlot(null);
            return;
        }

        if (currentSlot.storage.is_turtle && currentSlot.storage.storage_uuid != selectedSlot.storage.storage_uuid) {
            setCurrentSelectedSlot(null);
            return;
        }

        if (currentSlot.storage.is_turtle) {
            await sendStorageEvent(
                currentSlot.device_uuid,
                [
                    'moveTurtleItems',
                    String(currentSlot.slot),
                    String(selectedSlot.slot),
                    String(currentSlot.item.count)
                ]
            );

        } else {
            await sendStorageEvent(
                currentSlot.device_uuid,
                [
                    'moveItems',
                    currentSlot.storage.storage_uuid,
                    String(currentSlot.slot),
                    selectedSlot.storage.storage_uuid,
                    String(selectedSlot.slot),
                    String(currentSlot.item.count)
                ]
            );
        }

        setCurrentSelectedSlot(null);
        setTimeout(async () => {
            const storageUpdates: Promise<void>[] = [updateStorage(currentSlot.storage.storage_uuid)];
            if (currentSlot.storage.storage_uuid != selectedSlot.storage.storage_uuid) {
                storageUpdates.push(updateStorage(selectedSlot.storage.storage_uuid));
            }

            await Promise.all(storageUpdates);
        }, 500);
    }

    function getSelectedSlot(device_uuid: string, storage_uuid: string): number {
        if (!currentSelectedSlot) return -1;
        if (currentSelectedSlot.device_uuid !== device_uuid) return -1;
        if (currentSelectedSlot.storage.storage_uuid !== storage_uuid) return -1;
        return currentSelectedSlot.slot;
    }

    async function updateStorage(storageName: string) {
        const updatedStorage = await storageRepository.getStorage(storageName);
        setStorages(prev =>
            prev.map(storage =>
                storage.storage_uuid === updatedStorage.storage_uuid ? updatedStorage : storage
            )
        );
    }

    return (
        <div
            className="grid grid-cols-1 gap-4 px-4 *:data-[slot=card]:bg-gradient-to-t *:data-[slot=card]:from-primary/5 *:data-[slot=card]:to-card *:data-[slot=card]:shadow-xs lg:px-6 @xl/main:grid-cols-2 @5xl/main:grid-cols-4 dark:*:data-[slot=card]:bg-card">
            {
                devices.map((device) => {
                    const id = device.device_uuid;
                    const storage = storages.find((storage) => storage.storage_uuid === id)

                    if (!isDeviceOnline(id)) return null;

                    if (!buildWidthRefs.current[id]) {
                        buildWidthRefs.current[id] = createRef<HTMLInputElement>();
                        buildLengthRefs.current[id] = createRef<HTMLInputElement>();

                        mineWidthRefs.current[id] = createRef<HTMLInputElement>();
                        mineLengthRefs.current[id] = createRef<HTMLInputElement>();
                        mineHeightRefs.current[id] = createRef<HTMLInputElement>();
                    }

                    return (
                        <Card key={id} className="@container/card">
                            <CardHeader>
                                <CardTitle className="text-2xl font-semibold tabular-nums @[250px]/card:text-3xl">
                                    {device.name}
                                </CardTitle>
                                <CardDescription>{device.description}</CardDescription>
                            </CardHeader>
                            <CardFooter className="flex-col items-start gap-1.5 text-sm items-center justify-center">
                                <div className="flex flex-col items-center justify-center gap-4">

                                    <div className="flex gap-6 items-center justify-center">

                                        <div className="grid grid-cols-3 gap-2 items-center justify-center">
                                            <div></div>
                                            <Button className='cursor-pointer' size="icon-lg" variant="outline"
                                                    onClick={() => sendTurtleEvent(id, "forward")}>
                                                <IconArrowBigUp />
                                            </Button>
                                            <div></div>

                                            <Button className='cursor-pointer' size="icon-lg" variant="outline"
                                                    onClick={() => sendTurtleEvent(id, "turnLeft")}>
                                                <IconRotate2/>
                                            </Button>
                                            <div></div>
                                            <Button className='cursor-pointer' size="icon-lg" variant="outline"
                                                    onClick={() => sendTurtleEvent(id, "turnRight")}>
                                                <IconRotateClockwise2/>
                                            </Button>

                                            <div></div>
                                            <Button className='cursor-pointer' size="icon-lg" variant="outline"
                                                    onClick={() => sendTurtleEvent(id, "back")}>
                                                <IconArrowBigDown />
                                            </Button>
                                            <div></div>
                                        </div>

                                        <ButtonGroup
                                            orientation="vertical"
                                            className="h-fit"
                                        >
                                            <Button variant="outline" size="icon-lg"
                                                    className='cursor-pointer' onClick={() => sendTurtleEvent(id, "up")}>
                                                <IconEscalatorUp />
                                            </Button>
                                            <Button variant="outline" size="icon-lg"
                                                    className='cursor-pointer' onClick={() => sendTurtleEvent(id, "down")}>
                                                <IconEscalatorDown />
                                            </Button>
                                        </ButtonGroup>

                                        <div className="flex gap-2">
                                            <ButtonGroup
                                                orientation="vertical"
                                                className="h-fit"
                                            >
                                                <Button variant="outline" size="icon-lg"
                                                        className='cursor-pointer' onClick={() => sendTurtleEvent(id, "digUp", true)}>
                                                    <IconArrowBigUp />
                                                </Button>
                                                <Button variant="outline" size="icon-lg"
                                                        className='cursor-pointer' onClick={() => sendTurtleEvent(id, "dig", true)}>
                                                    <IconPick />
                                                </Button>
                                                <Button variant="outline" size="icon-lg"
                                                        className='cursor-pointer' onClick={() => sendTurtleEvent(id, "digDown", true)}>
                                                    <IconArrowBigDown />
                                                </Button>
                                            </ButtonGroup>

                                            <ButtonGroup
                                                orientation="vertical"
                                                className="h-fit"
                                            >
                                                <Button variant="outline" size="icon-lg"
                                                        className='cursor-pointer' onClick={() => sendTurtleEvent(id, "placeUp", true)}>
                                                    <IconArrowBigUp />
                                                </Button>
                                                <Button variant="outline" size="icon-lg"
                                                        className='cursor-pointer' onClick={() => sendTurtleEvent(id, "place", true)}>
                                                    <IconHammer />
                                                </Button>
                                                <Button variant="outline" size="icon-lg"
                                                        className='cursor-pointer' onClick={() => sendTurtleEvent(id, "placeDown", true)}>
                                                    <IconArrowBigDown />
                                                </Button>
                                            </ButtonGroup>

                                            <ButtonGroup
                                                orientation="vertical"
                                                className="h-fit"
                                            >
                                                <Button variant="outline" size="icon-lg"
                                                        className='cursor-pointer' onClick={() => sendTurtleEvent(id, "dropUp", true)}>
                                                    <IconArrowBigUp />
                                                </Button>
                                                <Button variant="outline" size="icon-lg"
                                                        className='cursor-pointer' onClick={() => sendTurtleEvent(id, "drop", true)}>
                                                    <IconStackPop />
                                                </Button>
                                                <Button variant="outline" size="icon-lg"
                                                        className='cursor-pointer' onClick={() => sendTurtleEvent(id, "dropDown", true)}>
                                                    <IconArrowBigDown />
                                                </Button>
                                            </ButtonGroup>

                                            <ButtonGroup
                                                orientation="vertical"
                                                className="h-fit"
                                            >
                                                <Button variant="outline" size="icon-lg"
                                                        className='cursor-pointer' onClick={() => sendTurtleEvent(id, "suckUp", true)}>
                                                    <IconArrowBigUp />
                                                </Button>
                                                <Button variant="outline" size="icon-lg"
                                                        className='cursor-pointer' onClick={() => sendTurtleEvent(id, "suck", true)}>
                                                    <IconStackPush />
                                                </Button>
                                                <Button variant="outline" size="icon-lg"
                                                        className='cursor-pointer' onClick={() => sendTurtleEvent(id, "suckDown", true)}>
                                                    <IconArrowBigDown />
                                                </Button>
                                            </ButtonGroup>
                                        </div>
                                    </div>
                                    <div className="flex flex-col gap-2 items-center justify-center py-8">
                                        {storage && (
                                            <>
                                                <StorageInventory
                                                    key={`turtle-${storage.storage_uuid}`}
                                                    storage={storage}
                                                    selectedSlot={getSelectedSlot(id, storage.storage_uuid)}
                                                    onSlotEventDoubleClick={(slot: number) =>
                                                        onSlotDoubleClick({
                                                            device_uuid: id,
                                                            storage: storage,
                                                            slot: slot,
                                                        })
                                                    }
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
                                                <Button className='w-full cursor-pointer' onClick={() => sendTurtleEvent(id, "craft", true)}>
                                                    Craft items
                                                </Button>
                                            </>
                                        )}
                                    </div>
                                    <div className="flex flex-col gap-2">
                                        <form className="w-full max-w-sm flex gap-2 items-end">
                                            <Field>
                                                <FieldLabel>Width</FieldLabel>
                                                <Input type="number"
                                                       placeholder="16"
                                                       ref={buildWidthRefs.current[id]}/>
                                            </Field>
                                            <Field>
                                                <FieldLabel>Length</FieldLabel>
                                                <Input type="number" placeholder="16"
                                                       ref={buildLengthRefs.current[id]}/>
                                            </Field>
                                        </form>

                                        <Button className='cursor-pointer' onClick={() => sendTurtleEvent(id, [
                                            "buildRoof",
                                            buildWidthRefs.current[id].current?.value ?? "0",
                                            buildLengthRefs.current[id].current?.value ?? "0",
                                        ])}>
                                            Build Roof
                                        </Button>
                                    </div>
                                    <div className="flex flex-col gap-2">
                                        <form className="w-full max-w-sm flex gap-2 items-end">
                                            <Field>
                                                <FieldLabel>Width</FieldLabel>
                                                <Input type="number" placeholder="16"
                                                       ref={mineWidthRefs.current[id]}/>
                                            </Field>
                                            <Field>
                                                <FieldLabel>Length</FieldLabel>
                                                <Input type="number" placeholder="16"
                                                       ref={mineLengthRefs.current[id]}/>
                                            </Field>
                                            <Field>
                                                <FieldLabel>Height</FieldLabel>
                                                <Input type="number" placeholder="256"
                                                       ref={mineHeightRefs.current[id]}/>
                                            </Field>
                                        </form>

                                        <Button className='cursor-pointer' onClick={() => sendTurtleEvent(id, [
                                            "chunkMiner",
                                            mineWidthRefs.current[id].current?.value ?? "0",
                                            mineLengthRefs.current[id].current?.value ?? "0",
                                            mineHeightRefs.current[id].current?.value ?? "0",])}>
                                            Mine Area
                                        </Button>
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
