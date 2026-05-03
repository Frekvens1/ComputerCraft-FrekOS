import type {DeviceState} from "@/core/modules/devices/models.ts";

type Props = {
    deviceState?: DeviceState;
}

export function DeviceIcon({deviceState}: Props) {
    function getDeviceImagePath(deviceState: DeviceState | undefined): string {
        if (deviceState == undefined) return '';
        const path = '/items/computercraft';
        const deviceType = deviceState.has_color ? 'advanced' : 'normal';

        switch (deviceState.type) {
            case 'command':
                return `${path}/computer_${deviceState.type}.png`;
            case 'pocket':
                return `${path}/${deviceState.type}_computer_${deviceType}.png`;
            default:
                return `${path}/${deviceState.type}_${deviceType}.png`;
        }
    }

    if (deviceState == undefined) {
        return (<></>);
    }

    return (
        <img className="h-32 w-auto object-contain"
             src={getDeviceImagePath(deviceState)}
             alt={deviceState?.type}/>
    )
}