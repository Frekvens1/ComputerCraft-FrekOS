import {BackendService} from '@/core/services/backend.service';

const backend = new BackendService();

export class TeleportRepository {
    async requestTeleport(): Promise<void> {
        return backend.get('/teleport');
    }
}