import {Button} from '@/components/ui/button';
import {
    Dialog,
    DialogClose,
    DialogContent,
    DialogFooter,
    DialogHeader,
    DialogTitle,
    DialogTrigger,
} from '@/components/ui/dialog';
import {Field, FieldGroup, FieldLabel} from '@/components/ui/field';
import {Input} from '@/components/ui/input';
import {Label} from '@/components/ui/label';
import type {DeviceData} from '@/core/modules/devices/models.ts';
import type {SubmitEvent} from 'react';
import {ToggleGroup, ToggleGroupItem} from "@/components/ui/toggle-group.tsx";

type Props = {
    onSubmit: (data: DeviceData) => void;
};


export function CreateDeviceDialog({onSubmit}: Props) {
    function handleSubmit(event: SubmitEvent<HTMLFormElement>) {
        event.preventDefault();

        const formData = new FormData(event.currentTarget);

        const data: DeviceData = {
            name: formData.get('name') as string,
            description: formData.get('description') as string,

            type: formData.get('type') as string,
        };

        console.log({
            data: data,
            formData: formData,
        })

        onSubmit(data);
    }

    return (
        <Dialog>
            <DialogTrigger asChild>
                <Button size='sm' className='cursor-pointer'>
                    Create device
                </Button>
            </DialogTrigger>

            <DialogContent className='sm:max-w-sm'>
                <form onSubmit={handleSubmit}>
                    <DialogHeader className='mb-8'>
                        <DialogTitle>Create device</DialogTitle>
                    </DialogHeader>

                    <Field className='mt-4'>
                        <FieldLabel>Device type</FieldLabel>
                        <input type="hidden" name="type" defaultValue='terminal'/>
                        <ToggleGroup
                            type="single"
                            variant="outline"
                            spacing={2}
                            size="lg"
                            defaultValue='terminal'
                            onValueChange={(value) => {
                                const hidden = document.querySelector('input[name="type"]') as HTMLInputElement;
                                hidden.value = value ?? "";
                            }}
                        >
                            <ToggleGroupItem
                                value="terminal"
                                aria-label="Light"
                                className="flex items-center justify-center rounded-xl cursor-pointer"
                            >
                                <span className="text-md">Terminal</span>
                            </ToggleGroupItem>
                            <ToggleGroupItem
                                value="storage_module"
                                aria-label="Normal"
                                className="flex items-center justify-center rounded-xl cursor-pointer"
                            >
                                <span className="text-md">Storage Module</span>
                            </ToggleGroupItem>
                            <ToggleGroupItem
                                value="teleport_module"
                                aria-label="Medium"
                                className="flex items-center justify-center rounded-xl cursor-pointer"
                            >
                                <span className="text-md">Teleport Module</span>
                            </ToggleGroupItem>
                            <ToggleGroupItem
                                value="miner"
                                aria-label="Light"
                                className="flex items-center justify-center rounded-xl cursor-pointer"
                            >
                                <span className="text-md">Miner</span>
                            </ToggleGroupItem>
                        </ToggleGroup>
                    </Field>

                    <FieldGroup className='mt-4'>
                        <Field>
                            <Label htmlFor='name'>Name</Label>
                            <Input id='name' name='name' required/>
                        </Field>

                        <Field>
                            <Label htmlFor='description'>Description</Label>
                            <Input id='description' name='description'/>
                        </Field>
                    </FieldGroup>

                    <DialogFooter className='mt-6'>
                        <DialogClose asChild>
                            <Button className='cursor-pointer' variant='outline'>Cancel</Button>
                        </DialogClose>
                        <DialogClose asChild>
                            <Button className='cursor-pointer' type='submit'>Create device</Button>
                        </DialogClose>
                    </DialogFooter>
                </form>
            </DialogContent>
        </Dialog>
    );
}
