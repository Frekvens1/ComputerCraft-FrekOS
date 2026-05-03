export interface Position {
    x: number;
    y: number;
    z: number;
}

export interface Peripheral {
    name: string;
    types: string[];
    methods: string[];
}

export type DeviceType = 'computer' | 'turtle' | 'pocket' | 'command';
export type DeviceSide = 'bottom' | 'top' | 'back' | 'front' | 'right' | 'left';
export type RedstoneType = 'input' | 'output';

export interface Redstone {
    side: DeviceSide;
    mode: RedstoneType;
    power: number;
}

export interface DeviceStateData {
    type: DeviceType;
    has_color: boolean;
    connected_peripherals: Peripheral[];

    current_volume?: number;
    fuel_amount?: number;
    fuel_amount_max?: number;
    gps_position?: Position;
    redstone?: Partial<Record<DeviceSide, Redstone>>;
}

export interface DeviceData {
    name: string;
    description: string;

    modules?: string[];

    use_gps?: boolean;
    password?: string;
    use_lockscreen?: boolean;
    debug_send_events?: boolean;

    custom_startup_script?: string;
    device_position?: Position;
}

export interface Device extends DeviceData {
    device_state?: DeviceStateData;
    device_uuid: string;
}

export interface DeviceState extends DeviceStateData {
    is_online: boolean;
    device_uuid: string;
}
