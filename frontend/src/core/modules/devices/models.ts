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

export interface DeviceState {
    is_online: boolean;

    id: string;
    type: DeviceType;
    has_color: boolean;
    connected_peripherals: {[key: string]: Peripheral};

    current_volume?: number;
    fuel_amount?: number;
    fuel_amount_max?: number;
    gps_position?: Position;
}

export interface DeviceData {
    name: string;
    device_name?: string;
    description: string;

    type: string;

    use_gps?: boolean;
    password?: string;
    use_lockscreen?: boolean;

    custom_startup_script?: string;
    device_position?: Position;
    device_state?: DeviceType;
}

export interface Device extends DeviceData {
    device_uuid: string;
}

export interface DeleteStatus {
    status: boolean;
    message?: string;
}
