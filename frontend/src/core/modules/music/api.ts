import {BackendService} from '@/core/services/backend.service';
import type {DFPWM, DFPWMData} from "@/core/modules/music/models.ts";
import type {DeleteResponse} from "@/core/modules/common/modules.ts";

const backend = new BackendService();

export class MusicRepository {
    async getAllDFPWM(): Promise<DFPWM[]> {
        return backend.get('/music/dfpwm');
    }

    async createDFPWM(dfpwm_data: DFPWMData, file: File): Promise<DFPWM> {
        const formData = new FormData();
        formData.append("dfpwm_data", JSON.stringify(dfpwm_data));
        formData.append("file", file);

        return backend.postForm('/music/dfpwm', formData);
    }

    async downloadDFPWM(dfpwm_uuid: string, filename: string): Promise<void> {
        await backend.download(`/music/dfpwm/${dfpwm_uuid}/download`, filename);
    }

    async getDFPWM(dfpwm_uuid: string): Promise<DFPWM> {
        return backend.get(`/music/dfpwm/${dfpwm_uuid}`);
    }

    async updateDFPWM(dfpwm_uuid: string, dfpwm_data: DFPWMData): Promise<DFPWM> {
        return backend.post(`/music/dfpwm/${dfpwm_uuid}`, dfpwm_data);
    }

    async deleteDFPWM(dfpwm_uuid: string): Promise<DeleteResponse> {
        return backend.delete(`/music/dfpwm/${dfpwm_uuid}`);
    }
}
