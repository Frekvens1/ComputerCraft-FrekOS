import { Assets } from 'pixi.js';

export const guiAssets = {
    headerLeft: '/gui/header-left.png',
    headerSlot: '/gui/header-slot.png',
    headerRight: '/gui/header-right.png',

    slotLeft: '/gui/slot-left.png',
    slot: '/gui/slot.png',
    slotEmpty: '/gui/slot-empty.png',
    slotRight: '/gui/slot-right.png',

    footerLeft: '/gui/footer-left.png',
    footerSlot: '/gui/footer-slot.png',
    footerRight: '/gui/footer-right.png',

    dirt: '/items/minecraft/dirt.png',
};

Assets.addBundle('gui', guiAssets);

export async function loadGuiAssets() {
    return await Assets.loadBundle('gui');
}
