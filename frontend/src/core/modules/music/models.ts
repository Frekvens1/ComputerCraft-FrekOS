// region { Music data }

export interface PlaylistData {
    name: string;
    dfpwm?: string[];
}


export interface DFPWMData {
    name: string;
    seconds?: number;
    size?: number;
}

// endregion

// region { Music types }

export interface Playlist extends PlaylistData {
    playlist_uuid: string;
}


export interface DFPWM extends DFPWMData {
    dfpwm_uuid: string;
    file_uuid: string;
    filename: string;
}

// endregion
