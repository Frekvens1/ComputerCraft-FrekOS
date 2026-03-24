import {BackendService} from '@/core/services/backend.service';

const backend = new BackendService();

export class TeleportRepository {
    async requestTeleport(device_uuid: string): Promise<void> {
        return backend.get(`/teleport/${device_uuid}`);
    }
}