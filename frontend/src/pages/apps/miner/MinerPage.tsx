import {Button} from "@/components/ui/button.tsx";
import {Card, CardDescription, CardFooter, CardHeader, CardTitle} from "@/components/ui/card.tsx";
import {createRef, type RefObject, useEffect, useRef, useState} from "react";
import type {Device} from "@/core/modules/devices/models.ts";
import {DeviceRepository} from "@/core/modules/devices/api.ts";
import {Field, FieldLabel} from "@/components/ui/field.tsx";
import {Input} from "@/components/ui/input.tsx";

const deviceRepository = new DeviceRepository();

export function MinerPage() {
    const [devices, setDevices] = useState<Device[]>([]);
    const [onlineDevices, setOnlineDevices] = useState<string[]>([]);

    const buildWidthRefs = useRef<Record<string, RefObject<HTMLInputElement | null>>>({});
    const buildLengthRefs = useRef<Record<string, RefObject<HTMLInputElement | null>>>({});

    const mineWidthRefs = useRef<Record<string, RefObject<HTMLInputElement | null>>>({});
    const mineLengthRefs = useRef<Record<string, RefObject<HTMLInputElement | null>>>({});
    const mineHeightRefs = useRef<Record<string, RefObject<HTMLInputElement | null>>>({});


    useEffect(() => {
        deviceRepository.getDevicesByType('miner').then((devices) => {
            setDevices(devices);
        });

        deviceRepository.getOnlineDevices().then((devices) => {
            setOnlineDevices(devices);
        });
    }, []);

    function isDeviceOnline(uuid: string): boolean {
        return onlineDevices.includes(uuid);
    }

    async function sendEvent(device_uuid: string, events: string | string[]): Promise<void> {
        const eventList = Array.isArray(events) ? events : [events]
        await deviceRepository.events.raw(device_uuid, ['frekos_turtle', ...eventList])
    }

    return (
        <div
            className="grid grid-cols-1 gap-4 px-4 *:data-[slot=card]:bg-gradient-to-t *:data-[slot=card]:from-primary/5 *:data-[slot=card]:to-card *:data-[slot=card]:shadow-xs lg:px-6 @xl/main:grid-cols-2 @5xl/main:grid-cols-4 dark:*:data-[slot=card]:bg-card">
            {
                devices.map((device) => {
                    const id = device.device_uuid;
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

                                    <div className="grid grid-cols-3 gap-2 items-center justify-center">
                                        <div></div>
                                        <Button className='cursor-pointer' onClick={() => sendEvent(id, "forward")}>↑</Button>
                                        <div></div>

                                        <Button className='cursor-pointer' onClick={() => sendEvent(id, "turnLeft")}>←</Button>
                                        <div></div>
                                        <Button className='cursor-pointer' onClick={() => sendEvent(id, "turnRight")}>→</Button>

                                        <div></div>
                                        <Button className='cursor-pointer' onClick={() => sendEvent(id, "back")}>↓</Button>
                                        <div></div>
                                    </div>

                                    <div className="flex gap-2">
                                        <Button className='cursor-pointer' onClick={() => sendEvent(id, "up")}>Up</Button>
                                        <Button className='cursor-pointer' onClick={() => sendEvent(id, "down")}>Down</Button>
                                    </div>
                                    <div className="flex gap-2">
                                        <Button className='cursor-pointer' onClick={() => sendEvent(id, "digUp")}>Dig Up</Button>
                                        <Button className='cursor-pointer' onClick={() => sendEvent(id, "dig")}>Dig</Button>
                                        <Button className='cursor-pointer' onClick={() => sendEvent(id, "digDown")}>Dig Down</Button>
                                    </div>
                                    <div className="flex gap-2">
                                        <Button className='cursor-pointer' onClick={() => sendEvent(id, "placeUp")}>Place Up</Button>
                                        <Button className='cursor-pointer' onClick={() => sendEvent(id, "place")}>Place</Button>
                                        <Button className='cursor-pointer' onClick={() => sendEvent(id, "placeDown")}>Place
                                            Down</Button>
                                    </div>
                                    <div className="grid grid-cols-4 gap-2 py-8">
                                        {Array.from({length: 16}, (_, i) => i + 1).map((slot) => (
                                            <Button className='cursor-pointer' onClick={() => sendEvent(id, ["select", String(slot)])}>
                                                Slot {String(slot).padStart(2, "0")}
                                            </Button>
                                        ))}
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

                                        <Button className='cursor-pointer' onClick={() => sendEvent(id, [
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

                                        <Button className='cursor-pointer' onClick={() => sendEvent(id, [
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
