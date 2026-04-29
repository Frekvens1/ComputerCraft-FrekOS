import {Card, CardContent, CardHeader, CardTitle} from '@/components/ui/card';

import {CreatePictureDialog} from "@/core/modules/picture/modals/CreatePictureDialog.tsx";
import {PictureRepository} from "@/core/modules/picture/api.ts";
import {ScrollArea} from "@/components/ui/scroll-area.tsx";
import {ConfirmDialog} from "@/core/modals/ConfirmDialog.tsx";
import {Button} from "@/components/ui/button.tsx";
import {Trash2} from "lucide-react";
import {useEffect, useState} from "react";
import type {CCPicture, CCPictureData} from "@/core/modules/picture/models.ts";

const pictureRepository = new PictureRepository();

export function PicturePage() {
    const [pictures, setPictures] = useState<CCPicture[]>([]);

    useEffect(() => {
        pictureRepository.getAllPictures().then((pictures) => {
            setPictures(pictures);
        });
    }, []);

    async function createPicture(pictureData: CCPictureData, file: File): Promise<void> {
        const picture = await pictureRepository.createPicture(pictureData, file);
        setPictures((prev) => [...prev, picture]);
    }

    async function removeDevice(pictureUUID: string) {
        await pictureRepository.deletePicture(pictureUUID);
        setPictures((prev) => prev.filter((d) => d.picture_uuid !== pictureUUID));
    }

    async function downloadFile(pictureUUID: string, filename: string) {
        await pictureRepository.downloadPicture(pictureUUID, filename);
    }

    return (
        <div className='px-4 lg:px-6 w-full flex flex-col'>
            <Card className='h-full flex flex-col'>
                <CardHeader className='flex flex-row items-center justify-between mx-1 border-b px-6'>
                    <CardTitle className='text-2xl'>Pictures</CardTitle>
                    <CreatePictureDialog onSubmit={createPicture}/>
                </CardHeader>
                <CardContent className="flex-1 overflow-hidden p-0">
                    <ScrollArea className="h-full">
                        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 p-6">
                            {pictures.map((picture) => (
                                <Card
                                    key={picture.picture_uuid}
                                    className="transition hover:bg-muted/50 group cursor-pointer"
                                >
                                    <CardHeader className="flex flex-col border-b pb-2">
                                        <div className="w-full flex flex-row items-center justify-between">
                                            <div className="w-full flex flex-row items-center gap-2">

                                                <CardTitle className="text-base">{picture.name}</CardTitle>
                                            </div>
                                            <ConfirmDialog
                                                title={`Remove dfpwm "${picture.name}"?`}
                                                description='This action cannot be undone.'
                                                onAction={() => removeDevice(picture.picture_uuid)}>
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
                                    </CardHeader>

                                    <CardContent className='flex flex-col gap-2'>
                                        <p>UUID: {picture.picture_uuid}</p>
                                        <p>File ID: {picture.file_uuid}</p>
                                        <p>Filename: {picture.filename}</p>
                                        <p>File size: {Math.round(picture.size / 1000)}KiB</p>

                                        <Button onClick={() => downloadFile(picture.picture_uuid, picture.filename)}>
                                            Download file
                                        </Button>
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
