import { Button } from '@/components/ui/button';
import {
    Dialog,
    DialogClose,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
    DialogTrigger,
} from '@/components/ui/dialog';
import { Field, FieldGroup } from '@/components/ui/field';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import type {DeviceData} from '@/core/modules/devices/models.ts';
import type {SubmitEvent} from 'react';

type Props = {
    onSubmit: (data: DeviceData) => void;
};


export function CreateDeviceDialog({ onSubmit }: Props) {
    function handleSubmit(event: SubmitEvent<HTMLFormElement>) {
        event.preventDefault();

        const formData = new FormData(event.currentTarget);

        const data: DeviceData = {
            name: formData.get('name') as string,
            description: formData.get('description') as string,
        };

        onSubmit(data);
    }

    return (
        <Dialog>
            <DialogTrigger asChild>
                <Button size='sm' className='cursor-pointer'>
                    Add device
                </Button>
            </DialogTrigger>

            <DialogContent className='sm:max-w-sm'>
                <form onSubmit={handleSubmit}>
                    <DialogHeader>
                        <DialogTitle>Add device</DialogTitle>
                        <DialogDescription>
                            Add a new CC:Tweaked device to your system.
                        </DialogDescription>
                    </DialogHeader>

                    <FieldGroup className='mt-4'>
                        <Field>
                            <Label htmlFor='name'>Name</Label>
                            <Input id='name' name='name' required />
                        </Field>

                        <Field>
                            <Label htmlFor='description'>Description</Label>
                            <Input id='description' name='description' />
                        </Field>
                    </FieldGroup>

                    <DialogFooter className='mt-6'>
                        <DialogClose asChild>
                            <Button className='cursor-pointer' variant='outline'>Cancel</Button>
                        </DialogClose>
                        <DialogClose asChild>
                            <Button className='cursor-pointer' type='submit'>Add device</Button>
                        </DialogClose>
                    </DialogFooter>
                </form>
            </DialogContent>
        </Dialog>
    );
}
