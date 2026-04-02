import {useEffect, useState} from 'react';
import {Button} from '@/components/ui/button';
import {Card, CardHeader, CardTitle, CardContent} from '@/components/ui/card';
import {ScrollArea} from '@/components/ui/scroll-area';
import {Trash2} from 'lucide-react';

import {ConfirmDialog} from "@/core/modals/ConfirmDialog.tsx";
import {MusicRepository} from "@/core/modules/music/api.ts";
import type {DFPWM, DFPWMData} from "@/core/modules/music/models.ts";
import {CreateDFPWMDialog} from "@/core/modules/music/modals/CreateDFPWMDialog.tsx";

const musicRepository = new MusicRepository();

export function MusicPage() {
    const [dfpwms, setDFPWM] = useState<DFPWM[]>([]);

    useEffect(() => {
        musicRepository.getAllDFPWM().then((dfpwm) => {
            setDFPWM(dfpwm);
        });
    }, []);

    async function addDFPWM(dfpwmData: DFPWMData, file: File): Promise<void> {
        const dfpwm = await musicRepository.createDFPWM(dfpwmData, file);
        setDFPWM((prev) => [...prev, dfpwm]);
    }

    async function removeDevice(dfpwmUUID: string) {
        await musicRepository.deleteDFPWM(dfpwmUUID);
        setDFPWM((prev) => prev.filter((d) => d.dfpwm_uuid !== dfpwmUUID));
    }

    return (
        <div className='px-4 lg:px-6 w-full flex flex-col'>
            <Card className='h-full flex flex-col'>
                <CardHeader className='flex flex-row items-center justify-between mx-1 border-b px-6'>
                    <CardTitle className='text-2xl'>DFPWM</CardTitle>
                    <CreateDFPWMDialog onSubmit={addDFPWM}/>
                </CardHeader>

                <CardContent className="flex-1 overflow-hidden p-0">
                    <ScrollArea className="h-full">
                        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 p-6">
                            {dfpwms.map((dfpwm) => (
                                <Card
                                    key={dfpwm.dfpwm_uuid}
                                    className="transition hover:bg-muted/50 group cursor-pointer"
                                >
                                    <CardHeader className="flex flex-col border-b pb-2">
                                        <div className="w-full flex flex-row items-center justify-between">
                                            <div className="w-full flex flex-row items-center gap-2">

                                                <CardTitle className="text-base">{dfpwm.name}</CardTitle>
                                            </div>
                                            <ConfirmDialog
                                                title={`Remove dfpwm "${dfpwm.name}"?`}
                                                description='This action cannot be undone.'
                                                onAction={() => removeDevice(dfpwm.dfpwm_uuid)}>
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
                                        <p>UUID: {dfpwm.dfpwm_uuid}</p>
                                        <p>File ID: {dfpwm.file_uuid}</p>
                                        <p>Filename: {dfpwm.filename}</p>
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
