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
import {Field, FieldLabel} from "@/components/ui/field.tsx";
import {ButtonGroup} from "@/components/ui/button-group.tsx";
import {Input} from "@/components/ui/input.tsx";

const deviceRepository = new DeviceRepository();

export function DevicesPage() {
    const [devices, setDevices] = useState<Device[]>([]);
    const [onlineDevices, setOnlineDevices] = useState<string[]>([]);

    useEffect(() => {
        deviceRepository.getDevices().then((devices) => {
            setDevices(devices);
        });

        deviceRepository.getOnlineDevices().then((devices) => {
            setOnlineDevices(devices);
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

    function getInstallURL(uuid: string) {
        return `wget run https://install.frekos.cc ${uuid}`;
    }

    function isDeviceOnline(uuid: string): boolean {
        return onlineDevices.includes(uuid);
    }

    return (
        <div className='px-4 lg:px-6 w-full flex flex-col'>
            <Card className='h-full flex flex-col'>
                <CardHeader className='flex flex-row items-center justify-between mx-1 border-b px-6'>
                    <CardTitle className='text-2xl'>Devices</CardTitle>
                    <CreateDeviceDialog onSubmit={addDevice}/> {/* TODO: #27 - Use /devices/new */}
                </CardHeader>

                <CardContent className="flex-1 overflow-hidden p-0">
                    <ScrollArea className="h-full">
                        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 p-6">
                            {devices.map((device) => (
                                <Card
                                    key={device.device_uuid}
                                    className="transition hover:bg-muted/50 group cursor-pointer"
                                >
                                    <CardHeader className="flex flex-col border-b pb-2">
                                        <div className="w-full flex flex-row items-center justify-between">
                                            <div className="w-full flex flex-row items-center gap-2">
                                                <StatusDot
                                                    status={isDeviceOnline(device.device_uuid) ? 'online' : 'offline'}/>
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
                                        {isDeviceOnline(device.device_uuid) ?
                                            (
                                                <>
                                                    <p>Device is online</p>
                                                    <p>Device ID</p>
                                                    <p>{device.device_uuid}</p>
                                                </>
                                            ) : (
                                                <Field className='max-w-lg'>
                                                    <FieldLabel htmlFor="input-install-url">Install</FieldLabel>
                                                    <ButtonGroup>
                                                        <Input id="input-install-url" disabled
                                                               value={getInstallURL(device.device_uuid)}/>
                                                        <Button variant="outline"
                                                                onClick={() => navigator.clipboard.writeText(getInstallURL(device.device_uuid))}>Copy</Button>
                                                    </ButtonGroup>
                                                </Field>
                                            )}
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
