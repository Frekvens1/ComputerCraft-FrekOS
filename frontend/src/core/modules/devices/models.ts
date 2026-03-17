export interface DeviceData {
    name: string,
    description: string,
}

export interface Device extends DeviceData {
    device_uuid: string,
}

export interface DeleteStatus {
    status: boolean,
    message?: string,
}