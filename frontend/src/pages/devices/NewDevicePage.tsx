import {Card, CardContent, CardDescription, CardHeader, CardTitle} from "@/components/ui/card.tsx";
import {Button} from "@/components/ui/button.tsx";
import {Field, FieldDescription, FieldLabel} from "@/components/ui/field.tsx";
import {Input} from "@/components/ui/input.tsx";
import {ButtonGroup} from "@/components/ui/button-group.tsx";

export function NewDevicePage() {
    return (
        <div className='px-4 lg:px-6 gap-6 flex flex-col'>
            <Card className="@container/card">
                <CardHeader>
                    <CardTitle>Device Information</CardTitle>
                </CardHeader>
                <CardContent className="px-2 pt-4 sm:px-6 sm:pt-6 flex flex-col gap-10">

                    <div className="flex flex-col gap-4">
                        <Field className='max-w-lg'>
                            <FieldLabel htmlFor="input-name">Name</FieldLabel>
                            <Input id="input-name" type="text" />
                            <FieldDescription>
                                Readable device name
                            </FieldDescription>
                        </Field>

                        <Field className='max-w-lg'>
                            <FieldLabel htmlFor="input-device-description">Description</FieldLabel>
                            <Input id="input-device-description" type="text" />
                            <FieldDescription>
                                Short description of device
                            </FieldDescription>
                        </Field>
                    </div>

                    <div className="flex flex-col gap-4">
                        <Field className='max-w-lg'>
                            <FieldLabel htmlFor="input-device-name">Device name</FieldLabel>
                            <Input id="input-device-name" type="text" />
                            <FieldDescription>
                                Device name set in-game
                            </FieldDescription>
                        </Field>

                        <Field className='max-w-lg'>
                            <FieldLabel htmlFor="input-password">Device password</FieldLabel>
                            <Input id="input-password" type="password" />
                            <FieldDescription>
                                Used for accessing device in-game. Hashed using SHA256 with salt.
                            </FieldDescription>
                        </Field>
                    </div>

                </CardContent>
            </Card>

            <Card className="@container/card">
                <CardHeader>
                    <CardTitle>Credentials</CardTitle>
                    <CardDescription>
                        <span className="card:block">This is how the device will authenticate with the server</span>
                    </CardDescription>
                </CardHeader>
                <CardContent className="px-2 pt-4 sm:px-6 sm:pt-6">

                </CardContent>
            </Card>

            <Card className="@container/card">
                <CardHeader>
                    <CardTitle>Install Site</CardTitle>
                    <CardDescription>
                        <span className="card:block">Install the device connector on your CC:Tweaked system</span>
                    </CardDescription>
                </CardHeader>
                <CardContent className="px-2 pt-4 sm:px-6 sm:pt-6">
                    <Field className='max-w-lg'>
                        <FieldLabel htmlFor="input-install-url">Install</FieldLabel>
                        <ButtonGroup>
                            <Input id="input-install-url" disabled value={`wget run https://install.frekos.cc/`}/>
                            <Button variant="outline" onClick={() => navigator.clipboard.writeText(`wget run https://install.frekos.cc/`)}>Copy</Button>
                        </ButtonGroup>
                    </Field>
                </CardContent>
            </Card>

            <div className='flex flex-row gap-2 justify-end'>
                <Button className='cursor-pointer' variant='outline'>Cancel</Button>
                <Button className='cursor-pointer' type='submit'>Create device</Button>
            </div>
        </div>
    )
}
