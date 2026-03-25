import type {DeleteStatus, Device, DeviceData} from '@/core/modules/devices/models.ts';
import {BackendService} from '@/core/services/backend.service';

const backend = new BackendService();

export class DeviceRepository {
    async getDevices(): Promise<Device[]> {
        return backend.get('/devices');
    }

    async getDevicesByType(device_type: string): Promise<Device[]> {
        return backend.get(`/devices/type/${device_type}`);
    }

    async getDevice(deviceUUID: string): Promise<Device> {
        return backend.get(`/device/${deviceUUID}`);
    }

    async createDevice(device: DeviceData): Promise<Device> {
        return backend.post('/device', device);
    }

    async deleteDevice(deviceUUID: string): Promise<boolean> {
        const response = await backend.delete<DeleteStatus>(`/device/${deviceUUID}`);
        return response.status;
    }

    async getOnlineDevices(): Promise<string[]> {
        return backend.get('/devices/online');
    }

    events = new class {
        async teleport(deviceUUID: string): Promise<void> {
            return backend.get(`/device/${deviceUUID}/events/teleport`);
        }
    }
}