'use client'

import * as React from 'react'
import {
    type IconProps,
    IconBuildingWarehouse,
    IconDashboard,
    IconDevices,
    IconHelicopter,
    IconInnerShadowTop,
    IconSettings,
    IconMusic, 
    IconPick,
} from '@tabler/icons-react'

import {NavDocuments} from '@/components/nav-documents'
import {NavMain} from '@/components/nav-main'
import {NavSecondary} from '@/components/nav-secondary'
import {NavUser} from '@/components/nav-user'
import {
    Sidebar,
    SidebarContent,
    SidebarFooter,
    SidebarHeader,
    SidebarMenu,
    SidebarMenuButton,
    SidebarMenuItem,
} from '@/components/ui/sidebar'
import {Link, useLocation} from 'react-router-dom';

type Icon = React.ForwardRefExoticComponent<IconProps & React.RefAttributes<SVGSVGElement>>;

export interface navigation {
    title: string;
    url: string;
    icon: Icon;
    isActive?: boolean;
}

const user = {
    name: 'admin',
    email: 'admin@frekos.cc',
    avatar: '/avatars/shadcn.jpg',
}

const data: { [p: string]: navigation[] } = {
    navMain: [
        {
            title: 'Dashboard',
            url: '/dashboard',
            icon: IconDashboard,
        },
        /*
        {
            title: 'Analytics',
            url: '/analytics',
            icon: IconChartBar,
        },
         */
        {
            title: 'Devices',
            url: '/devices',
            icon: IconDevices,
        },
    ],
    documents: [
        {
            title: 'Music',
            url: '/apps/music',
            icon: IconMusic,
        }, {
            title: 'Remote Miner',
            url: '/apps/miner',
            icon: IconPick,
        },
        /*
        {
            title: 'World Map',
            url: '/apps/map',
            icon: IconMap,
        },
         */
        {
            title: 'Storage Manager',
            url: '/apps/storage',
            icon: IconBuildingWarehouse,
        }, {
            title: 'Teleport Manager',
            url: '/apps/teleport',
            icon: IconHelicopter,
        },
        /*
        {
            title: 'Proximity Chat',
            url: '/apps/proximity-chat',
            icon: IconMicrophone,
        },
         */
    ],
    navSecondary: [
        {
            title: 'Settings',
            url: '/settings',
            icon: IconSettings,
        },
    ],
};

export function AppSidebar({...props}: React.ComponentProps<typeof Sidebar>) {
    const location = useLocation();

    const markActive = (items: navigation[]) =>
        items.map(item => ({
            ...item,
            isActive: location.pathname.startsWith(item.url),
        }));

    const navMain = markActive(data.navMain);
    const documents = markActive(data.documents);
    const navSecondary = markActive(data.navSecondary);

    return (
        <Sidebar collapsible='offcanvas' {...props}>
            <SidebarHeader>
                <SidebarMenu>
                    <SidebarMenuItem>
                        <SidebarMenuButton asChild className='data-[slot=sidebar-menu-button]:p-1.5!'>
                            <Link to={'/dashboard'} className='cursor-pointer'>
                                <IconInnerShadowTop className='size-5!'/>
                                <span className='text-base font-semibold'>FrekOS</span>
                            </Link>
                        </SidebarMenuButton>
                    </SidebarMenuItem>
                </SidebarMenu>
            </SidebarHeader>
            <SidebarContent>
                <NavMain items={navMain}/>
                <NavDocuments items={documents}/>
                <NavSecondary items={navSecondary} className='mt-auto'/>
            </SidebarContent>
            <SidebarFooter>
                <NavUser user={user}/>
            </SidebarFooter>
        </Sidebar>
    )
}
