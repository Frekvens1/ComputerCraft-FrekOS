import {Button} from "@/components/ui/button.tsx";
import {Card, CardDescription, CardFooter, CardHeader, CardTitle} from "@/components/ui/card.tsx";
import {useEffect, useState} from "react";
import type {Device} from "@/core/modules/devices/models.ts";
import {DeviceRepository} from "@/core/modules/devices/api.ts";

const deviceRepository = new DeviceRepository();

export function TeleportPage() {
    const [devices, setDevices] = useState<Device[]>([]);

    useEffect(() => {
        deviceRepository.getDevicesByType('teleport_module').then((devices) => {
            setDevices(devices);
        });
    }, []);

    return (
        <div
            className="grid grid-cols-1 gap-4 px-4 *:data-[slot=card]:bg-gradient-to-t *:data-[slot=card]:from-primary/5 *:data-[slot=card]:to-card *:data-[slot=card]:shadow-xs lg:px-6 @xl/main:grid-cols-2 @5xl/main:grid-cols-4 dark:*:data-[slot=card]:bg-card">

            {devices.map((device) => (
                <Card key={device.device_uuid} className="@container/card">
                    <CardHeader>
                        <CardTitle className="text-2xl font-semibold tabular-nums @[250px]/card:text-3xl">
                            {device.name}
                        </CardTitle>
                        <CardDescription>{device.description}</CardDescription>
                    </CardHeader>
                    <CardFooter className="flex-col items-start gap-1.5 text-sm">
                        <Button size='lg' className='cursor-pointer w-full'
                                onClick={() => deviceRepository.events.teleport(device.device_uuid)}>
                            Request teleport
                        </Button>
                    </CardFooter>
                </Card>
            ))}
        </div>
    )
}
