import './App.css'

import {createBrowserRouter, Navigate, RouterProvider} from 'react-router-dom';
import {DashboardPage} from '@/pages/dashboard/DashboardPage.tsx';
import {DevicesPage} from '@/pages/devices/DevicesPage.tsx';
import {SidebarLayout} from '@/pages/SidebarLayout.tsx';
import {TeleportPage} from '@/pages/apps/teleport/TeleportPage.tsx';
import {MinerPage} from "@/pages/apps/miner/MinerPage.tsx";
import {StoragePage} from "@/pages/apps/storage/StoragePage.tsx";
import {useEffect, useState} from "react";
import {loadGuiAssets} from "@/core/modules/storage/components/StorageAssets.ts";
import {MusicPage} from "@/pages/apps/music/MusicPage.tsx";
import {ShowDevicePage} from "@/pages/devices/ShowDevicePage.tsx";
import {PicturePage} from "@/pages/apps/pictures/PicturePage.tsx";

export interface RouterHandle {
    title: string;
}

const router = createBrowserRouter([
    {
        path: '/',
        element: <SidebarLayout/>,
        children: [
            {
                index: true,
                element: <Navigate to='/dashboard' replace/>,
            }, {
                path: 'dashboard',
                element: <DashboardPage/>,
                handle: {title: 'Dashboard'} as RouterHandle,
            }, {
                path: 'devices',
                children: [
                    {
                        index: true,
                        element: <DevicesPage/>,
                        handle: {title: 'Devices'} as RouterHandle,
                    }
                ]
            }, {
                path: 'device',
                children: [
                    {
                        index: true,
                        element: <Navigate to='/devices' replace/>,
                    }, {
                        path: ':device_uuid',
                        element: <ShowDevicePage/>,
                        handle: {title: 'Device'} as RouterHandle,
                    }
                ]
            }, {
                path: 'apps',
                children: [
                    {
                        index: true,
                        element: <Navigate to='storage' replace/>,
                    }, {
                        path: 'storage',
                        element: <StoragePage/>,
                        handle: {title: 'Storage Manager'} as RouterHandle,
                    }, {
                        path: 'teleport',
                        element: <TeleportPage/>,
                        handle: {title: 'Teleport Manager'} as RouterHandle,
                    }, {
                        path: 'miner',
                        element: <MinerPage/>,
                        handle: {title: 'Remote Miner'} as RouterHandle,
                    }, {
                        path: 'music',
                        element: <MusicPage/>,
                        handle: {title: 'Music'} as RouterHandle,
                    }, {
                        path: 'pictures',
                        element: <PicturePage/>,
                        handle: {title: 'Pictures'} as RouterHandle,
                    }, {
                        path: '*',
                        element: <Navigate to='/apps' replace/>,
                    },
                ]
            }, {
                path: '*',
                element: <Navigate to='/' replace/>,
            },
        ],
    },
]);

function App() {
    const [ready, setReady] = useState(false);

    useEffect(() => {
        loadGuiAssets().then(() => setReady(true));
    }, []);

    if (!ready) return (
        <div>
            <p>Loading...</p>
        </div>
    );

    return (
        <RouterProvider router={router}/>
    )
}

export default App
