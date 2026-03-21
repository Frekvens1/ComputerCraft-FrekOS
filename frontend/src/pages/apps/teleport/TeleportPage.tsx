import {Button} from "@/components/ui/button.tsx";
import {Card, CardDescription, CardFooter, CardHeader, CardTitle} from "@/components/ui/card.tsx";
import {TeleportRepository} from "@/core/modules/apps/teleport/api.ts";

const teleportRepository = new TeleportRepository();

export function TeleportPage() {
    return (
        <div
            className="grid grid-cols-1 gap-4 px-4 *:data-[slot=card]:bg-gradient-to-t *:data-[slot=card]:from-primary/5 *:data-[slot=card]:to-card *:data-[slot=card]:shadow-xs lg:px-6 @xl/main:grid-cols-2 @5xl/main:grid-cols-4 dark:*:data-[slot=card]:bg-card">
            <Card className="@container/card">
                <CardHeader>
                    <CardTitle className="text-2xl font-semibold tabular-nums @[250px]/card:text-3xl">
                        Home
                    </CardTitle>
                    <CardDescription>Basement</CardDescription>
                </CardHeader>
                <CardFooter className="flex-col items-start gap-1.5 text-sm">
                    <Button size='lg' className='cursor-pointer w-full'
                            onClick={teleportRepository.requestTeleport}>
                        Request teleport
                    </Button>
                </CardFooter>
            </Card>
        </div>
    )
}
