import {BackendService} from '@/core/services/backend.service';
import type {DeleteStorageResponse, Storage} from "@/core/modules/storage/models.ts";

const backend = new BackendService();

export class StorageRepository {
    async getStorages(): Promise<Storage[]> {
        return backend.get('/storages');
    }

    async getStoragesByDevice(device_uuid: string): Promise<Storage[]> {
        return backend.get(`/storages/device/${device_uuid}`);
    }

    async getStorage(storageName: string): Promise<Storage> {
        return backend.get(`/storage/${storageName}`);
    }

    async updateStorage(storageName: string, storage: Storage): Promise<Storage> {
        return backend.post(`/storage/${storageName}`, storage);
    }

    async deleteStorage(storageName: string): Promise<DeleteStorageResponse> {
        return backend.delete(`/storage/${storageName}`);
    }
}