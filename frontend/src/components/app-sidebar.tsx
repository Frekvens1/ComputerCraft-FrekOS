"use client"

import * as React from "react"
import {
    IconDashboard,
    IconDatabase,
    IconInnerShadowTop,
    IconListDetails,
    IconSettings,
} from "@tabler/icons-react"

import { NavDocuments } from "@/components/nav-documents"
import { NavMain } from "@/components/nav-main"
import { NavSecondary } from "@/components/nav-secondary"
import { NavUser } from "@/components/nav-user"
import {
    Sidebar,
    SidebarContent,
    SidebarFooter,
    SidebarHeader,
    SidebarMenu,
    SidebarMenuButton,
    SidebarMenuItem,
} from "@/components/ui/sidebar"

const data = {
    user: {
        name: "admin",
        email: "admin@frekos.cc",
        avatar: "/avatars/shadcn.jpg",
    },
    navMain: [
        {
            isActive: true,
            title: "Dashboard",
            url: "/dashboard",
            icon: IconDashboard,
        },
        /*
        {
            title: "Analytics",
            url: "/analytics",
            icon: IconChartBar,
        },
         */
        {
            title: "Devices",
            url: "/devices",
            icon: IconListDetails,
        },
    ],
    documents: [
        {
            title: "Storage",
            url: "/storage",
            icon: IconDatabase,
        },
    ],
    navSecondary: [
        {
            title: "Settings",
            url: "/settings",
            icon: IconSettings,
        },
    ],
}

export function AppSidebar({ ...props }: React.ComponentProps<typeof Sidebar>) {
    return (
        <Sidebar collapsible="offcanvas" {...props}>
            <SidebarHeader>
                <SidebarMenu>
                    <SidebarMenuItem>
                        <SidebarMenuButton
                            asChild
                            className="data-[slot=sidebar-menu-button]:p-1.5!"
                        >
                            <a href="/dashboard">
                                <IconInnerShadowTop className="size-5!" />
                                <span className="text-base font-semibold">FrekOS</span>
                            </a>
                        </SidebarMenuButton>
                    </SidebarMenuItem>
                </SidebarMenu>
            </SidebarHeader>
            <SidebarContent>
                <NavMain items={data.navMain} />
                <NavDocuments items={data.documents} />
                <NavSecondary items={data.navSecondary} className="mt-auto"/>
            </SidebarContent>
            <SidebarFooter>
                <NavUser user={data.user} />
            </SidebarFooter>
        </Sidebar>
    )
}
