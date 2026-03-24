import type {CSSProperties} from 'react';
import { Outlet, useMatches } from 'react-router-dom';

import { SidebarInset, SidebarProvider } from '@/components/ui/sidebar';
import { AppSidebar } from '@/components/app-sidebar';
import { SiteHeader } from '@/components/site-header';
import type {RouterHandle} from '@/App.tsx';

export function SidebarLayout() {
    const matches = useMatches();
    const currentPage = matches.find(m => (m.handle as RouterHandle)?.title);

    return (
        <SidebarProvider
            style={
                {
                    '--sidebar-width': 'calc(var(--spacing) * 72)',
                    '--header-height': 'calc(var(--spacing) * 12)',
                } as CSSProperties
            }
        >
            <AppSidebar variant='inset' />

            <SidebarInset>
                <SiteHeader title={(currentPage?.handle as RouterHandle)?.title ?? ''} />

                <div className='flex flex-1 flex-col'>
                    <div className='@container/main flex flex-1 flex-col gap-2'>
                        <div className='flex flex-col gap-4 py-4 md:gap-6 md:py-6'>

                            <Outlet />

                        </div>
                    </div>
                </div>
            </SidebarInset>
        </SidebarProvider>
    );
}
