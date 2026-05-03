import type {Device, DeviceData, DeviceState, DeviceStateData, DeviceType} from '@/core/modules/devices/models.ts';
import {BackendService} from '@/core/services/backend.service';
import type {DeleteResponse} from "@/core/modules/common/modules.ts";

const backend = new BackendService();

export class DeviceRepository {
    async getDevices(): Promise<Device[]> {
        return backend.get('/devices');
    }

    async getDevicesByModule(device_type: string): Promise<Device[]> {
        return backend.get(`/devices/module/${device_type}`);
    }

    async getDevicesByType(device_type: DeviceType): Promise<Device[]> {
        return backend.get(`/devices/type/${device_type}`);
    }

    async createDevice(device: DeviceData): Promise<Device> {
        return backend.post('/device', device);
    }

    async getDevice(deviceUUID: string): Promise<Device> {
        return backend.get(`/device/${deviceUUID}`);
    }

    async updateDevice(deviceUUID: string, device: DeviceData): Promise<DeviceState> {
        return backend.post(`/device/${deviceUUID}`, device);
    }

    async patchDevice(deviceUUID: string, device: Partial<DeviceData>): Promise<DeviceState> {
        return backend.patch(`/device/${deviceUUID}`, device);
    }

    async deleteDevice(deviceUUID: string): Promise<DeleteResponse> {
        return backend.delete(`/device/${deviceUUID}`);
    }

    async getOnlineDevices(): Promise<string[]> {
        return backend.get('/devices/online');
    }

    // region { device state }

    async getDeviceStates(): Promise<DeviceState[]> {
        return backend.get(`/devices/state`);
    }

    async getDeviceState(deviceUUID: string): Promise<DeviceState> {
        return backend.get(`/device/${deviceUUID}/state`);
    }

    async updateDeviceState(deviceUUID: string, device: DeviceStateData): Promise<DeviceState> {
        return backend.post(`/device/${deviceUUID}/state`, device);
    }

    async patchDeviceState(deviceUUID: string, device: DeviceStateData): Promise<DeviceState> {
        return backend.patch(`/device/${deviceUUID}/state`, device);
    }

    async deleteDeviceState(deviceUUID: string): Promise<DeleteResponse> {
        return backend.delete(`/device/${deviceUUID}/state`);
    }

    // endregion

    events = new class {
        async raw<T>(deviceUUID: string, data: T[] | T[][]): Promise<void> {
            return backend.post(`/device/${deviceUUID}/event`, data);
        }
        
        async teleport(deviceUUID: string): Promise<void> {
            return backend.get(`/device/${deviceUUID}/events/teleport`);
        }
    }
}