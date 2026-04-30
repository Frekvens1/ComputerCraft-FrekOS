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
import {Textarea} from "@/components/ui/textarea.tsx";
import {DeleteDialog} from "@/core/modals/DeleteDialog.tsx";

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

    const [device, setDevice] = useState<Device | null>(null);
    const [deviceState, setDeviceState] = useState<DeviceState | null>(null);

    const useLockscreen = watch('use_lockscreen');

    useEffect(() => {
        if (!device_uuid) return;
        deviceRepository.getDevice(device_uuid).then((device) => {
            setDevice(device);

            setValue('device_uuid', device_uuid);

            setValue('name', device.name);
            setValue('description', device.description ?? '');
            setValue('modules', device.modules ?? []);

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

    async function removeDevice(deviceUUID: string) {
        await deviceRepository.deleteDevice(deviceUUID);
        navigate('/devices');
    }

    function getInstallURL(device_uuid: string) {
        return `wget run https://install.frekos.cc ${device_uuid}`;
    }

    return (
        <form onSubmit={handleSubmit(onSubmit)}>
            <div className='px-4 lg:px-6 gap-6 flex flex-col'>
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
                                    <Input id='input-install-url' disabled value={getInstallURL(device_uuid)}/>
                                    <Button variant='outline' type="button"
                                            onClick={() => navigator.clipboard.writeText(getInstallURL(device_uuid))}>Copy</Button>
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

                        <Textarea {...register('custom_startup_script')} />
                    </CardContent>
                </Card>

                <div className='flex flex-row gap-2 justify-end'>
                    <DeleteDialog
                        title={`Remove device "${device.name}"?`}
                        description='This action cannot be undone.'
                        onAction={() => removeDevice(device.device_uuid)}>
                        <Button className='cursor-pointer' variant="destructive" type='button'>Delete</Button>
                    </DeleteDialog>
                    <Button className='cursor-pointer' type='submit'>Save settings</Button>
                </div>
            </div>
        </form>
    )
}
