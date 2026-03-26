import './App.css'

import {createBrowserRouter, Navigate, RouterProvider} from 'react-router-dom';
import {DashboardPage} from '@/pages/dashboard/DashboardPage.tsx';
import {DevicesPage} from '@/pages/devices/DevicesPage.tsx';
import {SidebarLayout} from '@/pages/SidebarLayout.tsx';
import {TeleportPage} from '@/pages/apps/teleport/TeleportPage.tsx';
import {NewDevicePage} from "@/pages/devices/NewDevicePage.tsx";
import {MinerPage} from "@/pages/apps/miner/MinerPage.tsx";

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
            },
            {
                path: 'dashboard',
                element: <DashboardPage/>,
                handle: {title: 'Dashboard'} as RouterHandle,
            },
            {
                path: 'devices',
                children: [
                    {
                        index: true,
                        element: <DevicesPage/>,
                        handle: {title: 'Devices'} as RouterHandle,
                    },
                    {
                        path: 'new',
                        element: <NewDevicePage/>,
                        handle: {title: 'Add device'} as RouterHandle,
                    }
                ]
            },
            {
                path: 'apps',
                children: [
                    {
                        index: true,
                        element: <Navigate to='teleport' replace/>,
                    },
                    {
                        path: 'teleport',
                        element: <TeleportPage/>,
                        handle: {title: 'Teleport Manager'} as RouterHandle,
                    },
                    {
                        path: 'miner',
                        element: <MinerPage/>,
                        handle: {title: 'Remote Miner'} as RouterHandle,
                    },
                    {
                        path: '*',
                        element: <Navigate to='/apps' replace/>,
                    },
                ]
            },
            {
                path: '*',
                element: <Navigate to='/' replace/>,
            },
        ],
    },
]);

function App() {
    return (
        <RouterProvider router={router}/>
    )
}

export default App
