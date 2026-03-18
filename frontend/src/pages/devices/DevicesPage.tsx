import {useEffect, useState} from 'react';
import {Button} from '@/components/ui/button';
import {Card, CardHeader, CardTitle, CardContent} from '@/components/ui/card';
import {ScrollArea} from '@/components/ui/scroll-area';
import {Trash2} from 'lucide-react';

import type {Device, DeviceData} from '@/core/modules/devices/models';
import {DeviceRepository} from '@/core/modules/devices/api.ts';
import {CreateDeviceDialog} from '@/core/modules/devices/modals/CreateDeviceDialog.tsx';
import {ConfirmDialog} from "@/core/modals/ConfirmDialog.tsx";
import {StatusDot} from "@/core/components/StatusDot.tsx";

const deviceRepository = new DeviceRepository();

export function DevicesPage() {
    const [devices, setDevices] = useState<Device[]>([]);

    useEffect(() => {
        deviceRepository.getDevices().then((devices) => {
            setDevices(devices);
        });
    }, []);

    async function addDevice(data: DeviceData) {
        const device = await deviceRepository.createDevice(data);
        setDevices((prev) => [...prev, device]);
    }

    async function removeDevice(deviceUUID: string) {
        await deviceRepository.deleteDevice(deviceUUID);
        setDevices((prev) => prev.filter((d) => d.device_uuid !== deviceUUID));
    }

    return (
        <div className='px-4 w-full max-w-4xl h-[80vh] flex flex-col'>
            <Card className='h-full flex flex-col'>
                <CardHeader className='flex flex-row items-center justify-between mx-1 border-b px-6'>
                    <CardTitle className='text-2xl'>Devices</CardTitle>
                    <CreateDeviceDialog onSubmit={addDevice}/>
                </CardHeader>

                <CardContent className="flex-1 overflow-hidden p-0">
                    <ScrollArea className="h-full">
                        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 p-6">
                            {devices.map((device) => (
                                <Card
                                    key={device.device_uuid}
                                    className="transition hover:bg-muted/50 group"
                                >
                                    <CardHeader className="flex flex-col pb-2">
                                        <div className="w-full flex flex-row items-center justify-between">
                                            <div className="w-full flex flex-row items-center gap-2">
                                                <StatusDot status={device.description ? 'online' : 'offline'}/>
                                                <CardTitle className="text-base">{device.name}</CardTitle>
                                            </div>
                                            <ConfirmDialog
                                                title={`Remove device "${device.name}"?`}
                                                description='This action cannot be undone.'
                                                onAction={() => removeDevice(device.device_uuid)}>
                                                <Button
                                                    variant="ghost"
                                                    size="icon"
                                                    className="
                                                        cursor-pointer text-red-500 hover:text-red-700 hover:bg-red-100
                                                        [@media(hover:none)]:opacity-100 transition-opacity duration-200
                                                        [@media(hover:hover)]:opacity-0 [@media(hover:hover)]:group-hover:opacity-100
                                                      "
                                                >
                                                    <Trash2 className="h-4 w-4"/>
                                                </Button>
                                            </ConfirmDialog>
                                        </div>
                                        <div className="w-full flex flex-row items-center">

                                            <p className="text-sm text-muted-foreground">
                                                {device.description}
                                            </p>
                                        </div>
                                    </CardHeader>

                                    <CardContent className='flex flex-col gap-2'>
                                        <p className="text-sm">
                                            Device UUID:
                                        </p>
                                        <p className="text-sm text-muted-foreground">
                                            {device.device_uuid}
                                        </p>
                                    </CardContent>
                                </Card>
                            ))}
                        </div>
                    </ScrollArea>
                </CardContent>
            </Card>
        </div>
    );
}
