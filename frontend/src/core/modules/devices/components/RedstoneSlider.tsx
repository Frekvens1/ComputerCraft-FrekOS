"use client"

import * as React from "react"

import { Label } from "@/components/ui/label.tsx"
import { Slider } from "@/components/ui/slider.tsx"
import {DeviceRepository} from "@/core/modules/devices/api.ts";
import type {Device, DeviceSide, DeviceState} from "@/core/modules/devices/models.ts";
import {useEffect} from "react";
import {Button} from "@/components/ui/button.tsx";

const deviceRepository = new DeviceRepository();

type Props = {
    device: Device;
    deviceState?: DeviceState;
    side: DeviceSide;
};

export function RedstoneSlider({device, deviceState, side}: Props) {
    const [value, setValue] = React.useState([0])

    async function sendEvent(events: string | string[]): Promise<void> {
        if (!device.device_uuid) return;
        if (!deviceState?.is_online) return;
        const eventList = Array.isArray(events) ? events : [events]
        await deviceRepository.events.raw(device.device_uuid, eventList)
    }

    async function valueChanged(value: number[]): Promise<void> {
        if (!deviceState?.is_online) return;

        setValue(value);
        await sendEvent(['frekos_redstone', 'output', side, `${value[0]}`]);
    }

    useEffect(() => {
        if (deviceState) {
            const power = deviceState.redstone?.[side]?.power;
            if (power) {
                setValue([power]);
            }
        }
    }, [deviceState, side]);

    return (
        <div className="grid w-full max-w-xs gap-3">
            <div className="flex items-center justify-between gap-2">
                <Label htmlFor="slider-demo-temperature">{side}</Label>
                <span className="text-sm text-muted-foreground">
                    {value}
                </span>
            </div>
            <Slider
                className="mx-auto w-full max-w-xs"
                max={15}
                step={1}
                value={value}
                onValueChange={valueChanged}
            />
            <div className="flex gap-2">
                <Button className='flex-1 cursor-pointer' variant='outline' onClick={() => valueChanged([0])}>Off</Button>
                <Button className='flex-1 cursor-pointer' variant='outline' onClick={() => valueChanged([15])}>On</Button>
            </div>
        </div>
    )
}
