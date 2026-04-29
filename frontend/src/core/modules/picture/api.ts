import {BackendService} from '@/core/services/backend.service';
import type {CCPicture, CCPictureData} from "@/core/modules/picture/models.ts";
import type {DeleteResponse} from "@/core/modules/common/modules.ts";

const backend = new BackendService();

export class PictureRepository {
    async getAllPictures(): Promise<CCPicture[]> {
        return backend.get('/pictures');
    }

    async createPicture(picture_data: CCPictureData, file: File): Promise<CCPicture> {
        const formData = new FormData();
        formData.append("picture_data", JSON.stringify(picture_data));
        formData.append("file", file);

        return backend.postForm('/picture', formData);
    }

    async downloadPicture(picture_uuid: string, filename: string): Promise<void> {
        await backend.download(`/picture/${picture_uuid}/bimg`, filename);
    }

    async getPicture(picture_uuid: string): Promise<CCPicture> {
        return backend.get(`/picture/${picture_uuid}`);
    }

    async updatePicture(picture_uuid: string, picture_data: CCPictureData): Promise<CCPicture> {
        return backend.post(`/picture/${picture_uuid}`, picture_data);
    }

    async deletePicture(picture_uuid: string): Promise<DeleteResponse> {
        return backend.delete(`/picture/${picture_uuid}`);
    }
}
