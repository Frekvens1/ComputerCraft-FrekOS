"use client"

import {
    SidebarGroup,
    SidebarMenu,
    SidebarMenuButton,
    SidebarMenuItem,
} from "@/components/ui/sidebar"
import type {navigation} from "@/components/app-sidebar.tsx";
import {Link} from "react-router-dom";

export function NavMain({items}: {items: navigation[]}) {
    return (
        <SidebarGroup className="group-data-[collapsible=icon]:hidden">
            <SidebarMenu>
                {items.map((item: navigation) => (
                    <SidebarMenuItem key={item.title}>
                        <SidebarMenuButton asChild data-active={item.isActive}>
                            <Link to={item.url} className="cursor-pointer">
                                <item.icon />
                                <span>{item.title}</span>
                            </Link>
                        </SidebarMenuButton>
                    </SidebarMenuItem>
                ))}
            </SidebarMenu>
        </SidebarGroup>
    )
}
