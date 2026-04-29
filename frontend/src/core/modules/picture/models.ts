// region { Picture data }

export interface CCPictureData {
    name: string;
}

// endregion

// region { Picture types }

export interface CCPicture extends CCPictureData {
    picture_uuid: string;
    file_uuid: string;
    filename: string;
    size: number;
}

// endregion
