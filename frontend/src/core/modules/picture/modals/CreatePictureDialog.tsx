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
import {Field, FieldGroup} from '@/components/ui/field';
import {Input} from '@/components/ui/input';
import {Label} from '@/components/ui/label';
import {type SubmitEvent, useState} from 'react';
import type {DFPWMData} from "@/core/modules/music/models.ts";
import {UploadDropzone} from "@/components/upload-dropzone.tsx";

type Props = {
    onSubmit: (data: DFPWMData, file: File) => void;
};


export function CreatePictureDialog({onSubmit}: Props) {
    const [files, setFiles] = useState<File[] | null>(null);

    function handleSubmit(event: SubmitEvent<HTMLFormElement>) {
        event.preventDefault();

        if (!files) return;

        const formData = new FormData(event.currentTarget);

        const data: DFPWMData = {
            name: formData.get('name') as string,
        };

        onSubmit(data, files[0]);
    }

    return (
        <Dialog>
            <DialogTrigger asChild>
                <Button size='sm' className='cursor-pointer'>
                    Upload picture
                </Button>
            </DialogTrigger>

            <DialogContent className='md:max-w-md'>
                <form onSubmit={handleSubmit}>
                    <DialogHeader className='mb-8'>
                        <DialogTitle>Create device</DialogTitle>
                    </DialogHeader>

                    <FieldGroup className='mt-4'>
                        <Field>
                            <Label htmlFor='name'>Name</Label>
                            <Input id='name' name='name' required/>
                        </Field>

                        <UploadDropzone
                            id='file'
                            onFileUpload={setFiles}
                            description={{
                                maxFiles: 1,
                            }}
                        />
                    </FieldGroup>

                    <DialogFooter className='mt-6'>
                        <DialogClose asChild>
                            <Button className='cursor-pointer' variant='outline'>Cancel</Button>
                        </DialogClose>
                        <DialogClose asChild>
                            <Button className='cursor-pointer' type='submit'>Upload picture</Button>
                        </DialogClose>
                    </DialogFooter>
                </form>
            </DialogContent>
        </Dialog>
    );
}
