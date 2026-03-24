import {
    Tooltip,
    TooltipContent,
    TooltipProvider,
    TooltipTrigger,
} from "@/components/ui/tooltip"

type Status = "online" | "offline"

export function StatusDot({status}: { status: Status }) {
    const isOnline = status === "online"

    return (
        <TooltipProvider>
            <Tooltip>
                <TooltipTrigger asChild>
                      <span
                          className={`
                          inline-block h-2 w-2 rounded-full
                          ${isOnline ? "bg-emerald-500" : "bg-red-500"}
                        `}
                          aria-label={isOnline ? "Online" : "Offline"}
                      />
                </TooltipTrigger>

                <TooltipContent side="top">
                    <p>{isOnline ? "Online" : "Offline"}</p>
                </TooltipContent>
            </Tooltip>
        </TooltipProvider>
    )
}
