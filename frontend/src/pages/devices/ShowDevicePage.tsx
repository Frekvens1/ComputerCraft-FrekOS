import {Card, CardContent, CardDescription, CardHeader, CardTitle} from '@/components/ui/card.tsx';
import {Button} from '@/components/ui/button.tsx';
import {Field, FieldContent, FieldDescription, FieldLabel, FieldTitle} from '@/components/ui/field.tsx';
import {Input} from '@/components/ui/input.tsx';
import {ButtonGroup} from '@/components/ui/button-group.tsx';
import {useNavigate, useParams} from 'react-router-dom';
import {useEffect, useState} from 'react';
import type {Device, DeviceState} from '@/core/modules/devices/models.ts';
import {DeviceRepository} from '@/core/modules/devices/api.ts';
import {useForm} from 'react-hook-form';
import {ToggleGroup, ToggleGroupItem} from '@/components/ui/toggle-group.tsx';
import {IconBuildingWarehouse, IconHelicopter} from '@tabler/icons-react';
import {Checkbox} from '@/components/ui/checkbox.tsx';
import {DeleteDialog} from "@/core/modals/DeleteDialog.tsx";
import {Tabs, TabsContent, TabsList, TabsTrigger} from "@/components/ui/tabs.tsx";
import {AutosizeTextarea} from "@/components/ui/autosize-textarea.tsx";
import {RedstoneSlider} from "@/core/modules/devices/components/RedstoneSlider.tsx";
import {DeviceIcon} from "@/core/modules/devices/components/DeviceIcon.tsx";

const deviceRepository = new DeviceRepository();

export function ShowDevicePage() {
    const {device_uuid} = useParams();
    const navigate = useNavigate();
    const {register, handleSubmit, setValue, watch} = useForm<Device>();
    const onSubmit = (data: Device) => {
        deviceRepository.updateDevice(device_uuid!, data).then(() => {
            navigate(0);
        });
    }

    const [device, setDevice] = useState<Device | undefined>(undefined);
    const [deviceState, setDeviceState] = useState<DeviceState | undefined>(undefined);

    const useLockscreen = watch('use_lockscreen');

    useEffect(() => {
        if (!device_uuid) return;
        deviceRepository.getDevice(device_uuid).then((device) => {
            setDevice(device);

            setValue('device_uuid', device_uuid);

            setValue('name', device.name);
            setValue('description', device.description ?? '');
            setValue('modules', device.modules ?? []);

            setValue('debug_send_events', device.debug_send_events ?? false);
            setValue('use_lockscreen', device.use_lockscreen ?? false);
            setValue('password', device.password ?? '');

            setValue('custom_startup_script', device.custom_startup_script ?? '');
        });

        deviceRepository.getDeviceState(device_uuid).then((deviceState) => {
            setDeviceState(deviceState);
        });
    }, [device_uuid, setValue]);

    if (!device_uuid || !device) {
        return (
            <div className='px-4 lg:px-6 gap-6 flex flex-col'>
                <p>404 - Device not found</p>
            </div>
        )
    }

    async function removeDevice() {
        if (!device_uuid) return;
        await deviceRepository.deleteDevice(device_uuid);
        navigate('/devices');
    }

    function getInstallURL() {
        return `wget run https://install.frekos.cc ${device_uuid}`;
    }

    return (
        <div className='px-4 lg:px-6 flex flex-col'>
            <Tabs defaultValue="settings">
                <TabsList variant="line" className='mb-2'>
                    <TabsTrigger className='cursor-pointer' value="settings">Settings</TabsTrigger>
                    <TabsTrigger className='cursor-pointer' value="state">State</TabsTrigger>
                </TabsList>
                <TabsContent value="settings">
                    <form onSubmit={handleSubmit(onSubmit)}>
                        <div className='flex flex-col gap-6'>
                            {!deviceState && (
                                <Card className='@container/card'>
                                    <CardHeader>
                                        <CardTitle>Install Site</CardTitle>
                                        <CardDescription>
                                <span
                                    className='card:block'>Install the device connector on your CC:Tweaked system</span>
                                        </CardDescription>
                                    </CardHeader>
                                    <CardContent className='px-2 pt-4 sm:px-6 sm:pt-6'>
                                        <Field className='max-w-lg'>
                                            <FieldLabel htmlFor='input-install-url'>Install</FieldLabel>
                                            <ButtonGroup>
                                                <Input id='input-install-url' disabled value={getInstallURL()}/>
                                                <Button variant='outline' type="button"
                                                        onClick={() => navigator.clipboard.writeText(getInstallURL())}>Copy</Button>
                                            </ButtonGroup>
                                        </Field>
                                    </CardContent>
                                </Card>
                            )}

                            <Card className='@container/card'>
                                <CardHeader>
                                    <CardTitle>Device Settings</CardTitle>
                                </CardHeader>
                                <CardContent className='px-2 pt-4 sm:px-6 sm:pt-6 flex flex-col gap-10'>

                                    <div className='flex flex-col gap-4'>
                                        <Field className='max-w-lg'>
                                            <FieldLabel htmlFor='input-name'>Name</FieldLabel>
                                            <Input type='text' {...register('name')}/>
                                            <FieldDescription>
                                                Readable device name
                                            </FieldDescription>
                                        </Field>

                                        <Field className='max-w-lg'>
                                            <FieldLabel htmlFor='input-device-description'>Description</FieldLabel>
                                            <Input type='text' {...register('description')}/>
                                            <FieldDescription>
                                                Short description of device
                                            </FieldDescription>
                                        </Field>
                                    </div>

                                    <Field className='max-w-lg'>
                                        <FieldLabel htmlFor='input-password'>Modules</FieldLabel>
                                        <FieldDescription>
                                            Select which modules to activate
                                        </FieldDescription>
                                        <ToggleGroup
                                            type='multiple'
                                            defaultValue={device.modules ?? []}
                                            onValueChange={(value) => setValue('modules', value)}
                                            variant='outline'
                                            spacing={2}
                                            size='lg'
                                            {...register('modules')}
                                        >
                                            <ToggleGroupItem
                                                value='storage_module'
                                                aria-label='Storage'
                                                className='flex size-20 flex-col items-center justify-center rounded-xl cursor-pointer'
                                            >
                                                <IconBuildingWarehouse className='size-10' stroke={1.5} size={64}/>
                                                <span className='text-xs text-muted-foreground'>Storage</span>
                                            </ToggleGroupItem>
                                            <ToggleGroupItem
                                                value='teleport_module'
                                                aria-label='Teleport'
                                                className='flex size-20 flex-col items-center justify-center rounded-xl cursor-pointer'
                                            >
                                                <IconHelicopter className='size-10' stroke={1.5} size={64}/>
                                                <span className='text-xs text-muted-foreground'>Teleport</span>
                                            </ToggleGroupItem>

                                        </ToggleGroup>
                                    </Field>

                                    <div className='flex flex-col gap-4'>
                                        <FieldLabel className='max-w-lg cursor-pointer'>
                                            <Field orientation='horizontal'>
                                                <Checkbox {...register('debug_send_events')}
                                                          defaultChecked={device.debug_send_events}
                                                          onCheckedChange={(value) => setValue("debug_send_events", value === true)}/>
                                                <FieldContent>
                                                    <FieldTitle>Enable debug events</FieldTitle>
                                                    <FieldDescription>
                                                        Used for debugging. Sends all events from device to backend.
                                                    </FieldDescription>
                                                </FieldContent>
                                            </Field>
                                        </FieldLabel>

                                        <FieldLabel className='max-w-lg cursor-pointer'>
                                            <Field orientation='horizontal'>
                                                <Checkbox {...register('use_lockscreen')}
                                                          defaultChecked={device.use_lockscreen}
                                                          onCheckedChange={(value) => setValue("use_lockscreen", value === true)}/>
                                                <FieldContent>
                                                    <FieldTitle>Enable lockscreen</FieldTitle>
                                                    <FieldDescription>
                                                        Require the user to enter a password on boot.
                                                    </FieldDescription>
                                                </FieldContent>
                                            </Field>
                                        </FieldLabel>

                                        {useLockscreen && (
                                            <Field className='max-w-lg'>
                                                <FieldLabel htmlFor='input-password'>Device password</FieldLabel>
                                                <Input type='password' {...register('password')}/>
                                                <FieldDescription>
                                                    Used for accessing device in-game. Hashed using SHA256 with salt.
                                                </FieldDescription>
                                            </Field>
                                        )}
                                    </div>

                                    <Field>
                                        <FieldLabel htmlFor='input-custom_startup_script'>Custom startup script</FieldLabel>
                                        <AutosizeTextarea {...register('custom_startup_script')} />
                                        <FieldDescription>
                                            Lua code which runs inside shell at startup
                                        </FieldDescription>
                                    </Field>
                                </CardContent>
                            </Card>

                            <div className='flex flex-row gap-2 justify-end'>
                                <DeleteDialog
                                    title={`Remove device "${device.name}"?`}
                                    description='This action cannot be undone.'
                                    onAction={() => removeDevice()}>
                                    <Button className='cursor-pointer' variant="destructive" type='button'>Delete</Button>
                                </DeleteDialog>
                                <Button className='cursor-pointer' type='submit'>Save settings</Button>
                            </div>
                        </div>
                    </form>
                </TabsContent>
                <TabsContent value="state">
                    <div className='flex flex-col gap-3'>
                        <Card className='@container/card'>
                            <CardHeader>
                                <CardTitle>Device State</CardTitle>
                            </CardHeader>
                            <CardContent className='px-2 pt-4 sm:px-6 sm:pt-6 flex flex-col gap-10'>
                                <div className='flex flex-row gap-3'>
                                    <DeviceIcon deviceState={deviceState}/>
                                    <div className='flex flex-col gap-2 justify-center'>
                                        <p>{deviceState?.is_online ? 'Device is online' : 'Device is offline'}</p>
                                    </div>
                                </div>
                            </CardContent>
                        </Card>

                        <Card className='@container/card'>
                            <CardHeader>
                                <CardTitle>Redstone State</CardTitle>
                            </CardHeader>
                            <CardContent className='px-2 pt-4 sm:px-6 sm:pt-6 flex flex-col gap-10'>
                                <RedstoneSlider device={device} deviceState={deviceState} side={'top'} />
                                <RedstoneSlider device={device} deviceState={deviceState} side={'bottom'} />
                                <RedstoneSlider device={device} deviceState={deviceState} side={'left'} />
                                <RedstoneSlider device={device} deviceState={deviceState} side={'right'} />
                                <RedstoneSlider device={device} deviceState={deviceState} side={'front'} />
                                <RedstoneSlider device={device} deviceState={deviceState} side={'back'} />
                            </CardContent>
                        </Card>
                    </div>
                </TabsContent>
            </Tabs>
        </div>
    )
}
