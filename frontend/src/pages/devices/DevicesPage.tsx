import {useEffect, useState} from 'react';
import {Button} from '@/components/ui/button';
import {Card, CardHeader, CardTitle, CardContent} from '@/components/ui/card';
import {ScrollArea} from '@/components/ui/scroll-area';
import {Trash2} from 'lucide-react';

import type {Device} from '@/core/modules/devices/models';
import {DeviceRepository} from '@/core/modules/devices/api.ts';
import {StatusDot} from "@/core/components/StatusDot.tsx";
import {DeviceTable} from "@/components/device-table.tsx";
import {useNavigate} from "react-router-dom";
import {DeleteDialog} from "@/core/modals/DeleteDialog.tsx";

const deviceRepository = new DeviceRepository();

export function DevicesPage() {
    const navigate = useNavigate();
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

    async function createDevice() {
        const device = await deviceRepository.createDevice({name: 'FrekOS Device', description: ''});
        navigator.clipboard.writeText(getInstallURL(device.device_uuid)).catch(() => {});
        showDevice(device.device_uuid);
    }

    async function removeDevice(deviceUUID: string) {
        await deviceRepository.deleteDevice(deviceUUID);
        setDevices((prev) => prev.filter((d) => d.device_uuid !== deviceUUID));
    }

    function isDeviceOnline(device_uuid: string): boolean {
        return onlineDevices.includes(device_uuid);
    }

    function showDevice(deviceUUID: string) {
        navigate(`/device/${deviceUUID}`);
    }

    function getInstallURL(device_uuid: string) {
        return `wget run https://install.frekos.cc ${device_uuid}`;
    }

    return (
        <div className='px-4 lg:px-6 w-full flex flex-col'>
            <Card className='h-full flex flex-col'>
                <CardHeader className='flex flex-row items-center justify-between mx-1 border-b px-6'>
                    <CardTitle className='text-2xl'>Devices</CardTitle>
                    <Button size='sm' className='cursor-pointer'
                            onClick={createDevice}>
                        Create device
                    </Button>
                </CardHeader>

                { /* <div className="flex flex-col block lg:hidden"> */ }
                <CardContent className="flex-1 overflow-hidden px-0 lg:px-4">
                    <div className="flex flex-col">
                        <ScrollArea className="h-full">
                            <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 p-6">
                                {devices.map((device) => (
                                    <Card
                                        key={device.device_uuid}
                                        className="transition hover:bg-muted/50 group cursor-pointer"
                                        onClick={() => showDevice(device.device_uuid)}
                                    >
                                        <CardHeader className="flex flex-col border-b pb-2">
                                            <div className="w-full flex flex-row items-center justify-between">
                                                <div className="w-full flex flex-row items-center gap-2">
                                                    <StatusDot
                                                        status={isDeviceOnline(device.device_uuid) ? 'online' : 'offline'}/>
                                                    <CardTitle className="text-base">{device.name}</CardTitle>
                                                </div>
                                                <DeleteDialog
                                                    title={`Remove device "${device.name}"?`}
                                                    description='This action cannot be undone.'
                                                    onAction={() => removeDevice(device.device_uuid)}>
                                                    <Button
                                                        variant="ghost"
                                                        size="icon"
                                                        onClick={(e) => e.stopPropagation()}
                                                        className="
                                                        cursor-pointer text-red-500 hover:text-red-700 hover:bg-red-100
                                                        [@media(hover:none)]:opacity-100 transition-opacity duration-200
                                                        [@media(hover:hover)]:opacity-0 [@media(hover:hover)]:group-hover:opacity-100
                                                      "
                                                    >
                                                        <Trash2 className="h-4 w-4"/>
                                                    </Button>
                                                </DeleteDialog>
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
                                                        {(device.modules?.length ?? 0) > 0 && (
                                                            <>
                                                                <h3 className="text-lg">Device modules:</h3>
                                                                <p>{device.modules?.join(', ')}</p>
                                                                <br/>
                                                            </>
                                                        )}

                                                        <h3 className="text-lg">Device ID</h3>
                                                        <p>{device.device_uuid}</p>
                                                    </>
                                                ) : (
                                                    <>
                                                        <p>Device is offline</p>
                                                    </>
                                                )}
                                        </CardContent>
                                    </Card>
                                ))}
                            </div>
                        </ScrollArea>

                    </div>

                    { /* <div className="flex flex-col hidden lg:block"> */ }
                    <div className="flex flex-col hidden">
                        <DeviceTable columns={[
                            {
                                accessorKey: "is_online",
                                header: "Status",
                            }, {
                                accessorKey: "name",
                                header: "Name",
                            }, {
                                accessorKey: "description",
                                header: "Description",
                            }, {
                                accessorKey: "device_uuid",
                                header: "Device UUID",
                            },
                        ]} data={devices}/>
                    </div>
                </CardContent>
            </Card>
        </div>
    );
}
