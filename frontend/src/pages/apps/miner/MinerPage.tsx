import {Button} from "@/components/ui/button.tsx";
import {Card, CardDescription, CardFooter, CardHeader, CardTitle} from "@/components/ui/card.tsx";
import {useEffect, useState} from "react";
import type {Device} from "@/core/modules/devices/models.ts";
import {DeviceRepository} from "@/core/modules/devices/api.ts";

const deviceRepository = new DeviceRepository();

export function MinerPage() {
    const [devices, setDevices] = useState<Device[]>([]);
    const [onlineDevices, setOnlineDevices] = useState<string[]>([]);

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

    async function sendEvent(device_uuid: string, event: string): Promise<void> {
        await deviceRepository.events.raw(device_uuid, ['frekos_turtle', event])
    }

    return (
        <div
            className="grid grid-cols-1 gap-4 px-4 *:data-[slot=card]:bg-gradient-to-t *:data-[slot=card]:from-primary/5 *:data-[slot=card]:to-card *:data-[slot=card]:shadow-xs lg:px-6 @xl/main:grid-cols-2 @5xl/main:grid-cols-4 dark:*:data-[slot=card]:bg-card">

            {devices.map((device) =>
                isDeviceOnline(device.device_uuid) && (
                    <Card key={device.device_uuid} className="@container/card">
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
                                    <Button onClick={() => sendEvent(device.device_uuid, "forward")}>↑</Button>
                                    <div></div>

                                    <Button onClick={() => sendEvent(device.device_uuid, "turnLeft")}>←</Button>
                                    <div></div>
                                    <Button onClick={() => sendEvent(device.device_uuid, "turnRight")}>→</Button>

                                    <div></div>
                                    <Button onClick={() => sendEvent(device.device_uuid, "back")}>↓</Button>
                                    <div></div>
                                </div>

                                <div className="flex gap-2">
                                    <Button onClick={() => sendEvent(device.device_uuid, "up")}>Up</Button>
                                    <Button onClick={() => sendEvent(device.device_uuid, "down")}>Down</Button>
                                    <Button onClick={() => sendEvent(device.device_uuid, "dig")}>Dig</Button>
                                </div>
                            </div>
                        </CardFooter>
                    </Card>
                ))}
        </div>
    )
}
