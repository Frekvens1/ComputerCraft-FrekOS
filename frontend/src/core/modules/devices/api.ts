import type {DeleteStatus, Device, DeviceData} from '@/core/modules/devices/models.ts';
import {BackendService} from '@/core/services/backend.service';

const backend = new BackendService();

export class DeviceRepository {
    async getDevices(): Promise<Device[]> {
        return backend.get('/devices');
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
}