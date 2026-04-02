export class BackendService {

    private readonly basePath = '/api/';
    private readonly serverUrl: string;

    constructor() {
        this.serverUrl = window.location.origin;
        if (this.serverUrl.endsWith('/')) {
            this.serverUrl = this.serverUrl.slice(0, -1);
        }
    }

    private buildUrl(url: string): string {
        if (url.startsWith('/')) {
            url = url.substring(1);
        }

        return `${this.serverUrl}${this.basePath}${url}`;
    }

    websocket(url: string): WebSocket {
        /**
         * Establish a duplex connection with the server
         * @param url - Websocket query for server
         * @returns WebSocket - Active WebSocket connection with the server
         * */

        const urlFull = this.buildUrl(url).replace('http', 'ws');
        return new WebSocket(urlFull);
    }

    async get<T>(url: string): Promise<T> {
        /**
         * GET is used to retrieve data from the database
         * @param url - Query for server
         * @returns {} - JSONObject from database
         * */

        const response = await fetch(this.buildUrl(url), {
            method: 'GET',
            credentials: 'include'
        });
        return await response.json();
    }

    async post<T, B>(url: string, body: B): Promise<T> {
        /**
         * POST creates a new resource in the database
         * @param url - Query for server
         * @param body - Sent as JSON data
         * @returns {} - JSONObject response from server
         * */

        const response = await fetch(this.buildUrl(url), {
            method: 'POST',
            credentials: 'include',
            headers: {
                'Content-Type': 'application/json; charset=utf-8'
            },
            body: JSON.stringify(body ?? {})
        });
        return await response.json();
    }

    async postForm<T>(url: string, body: FormData): Promise<T> {
        /**
         * POST creates a new resource in the database
         * @param url - Query for server
         * @param body - Sent as FormData
         * @returns {} - JSONObject response from server
         * */

        const response = await fetch(this.buildUrl(url), {
            method: 'POST',
            credentials: 'include',
            body: body,
        });

        if (!response.ok) {
            throw new Error("FormData upload failed");
        }

        return await response.json();
    }

    async put<T, B>(url: string, body: B): Promise<T> {
        /**
         * PUT is used to update all fields in an existing resource in the database
         * @param url - Query for server
         * @param body - Sent as JSON data
         * @returns {} - JSONObject response from server
         * */

        const response = await fetch(this.buildUrl(url), {
            method: 'PUT',
            credentials: 'include',
            headers: {
                'Content-Type': 'application/json; charset=utf-8'
            },
            body: JSON.stringify(body ?? {})
        });
        return await response.json();
    }

    async patch<T, B>(url: string, body: B): Promise<T> {
        /**
         * PATCH is used to update partial changes to an existing resource in the database
         * @param url - Query for server
         * @param body - Sent as JSON data
         * @returns {} - JSONObject response from server
         * */

        const response = await fetch(this.buildUrl(url), {
            method: 'PATCH',
            credentials: 'include',
            headers: {
                'Content-Type': 'application/json; charset=utf-8'
            },
            body: JSON.stringify(body ?? {})
        });
        return await response.json();
    }

    async delete<T>(url: string): Promise<T> {
        /**
         * DELETE is used to delete a resource in the database
         * @param url - Resource path
         * @returns {} - JSONObject response from server
         * */
        console.log(`Deleting ${url}`);
        const response = await fetch(this.buildUrl(url), {
            method: 'DELETE',
            credentials: 'include',
            headers: {
                'Content-Type': 'application/json; charset=utf-8'
            },
        });
        return await response.json();
    }
}
