import {
    Application,
    extend,
} from '@pixi/react'
import {
    Assets,
    Container,
    Graphics,
    Sprite,
    Texture,
    Text,
} from 'pixi.js'
import {useEffect, useState} from 'react'
import type {Storage, StorageItem} from "@/core/modules/storage/models.ts";
import {ItemSlot} from "@/core/modules/storage/components/ItemSlot.tsx";

extend({
    Container,
    Graphics,
    Sprite,
    Text,
})

type Props = {
    storage: Storage;
    selectedSlot: number;
    onSlotEventClick?: (slot: number) => Promise<void>;
    onSlotEventDoubleClick?: (slot: number) => Promise<void>;
    onItemEventClick?: (item: StorageItem, slot: number) => Promise<void>;
    onItemEventDoubleClick?: (item: StorageItem, slot: number) => Promise<void>;
};

const SLOTS_MULTIPLIER = 4; // scale: 16/18 * SLOTS_MULTIPLIER
const DOUBLE_TAP_DELAY = 250; // ms

export function StorageInventory({storage, selectedSlot, onSlotEventClick, onSlotEventDoubleClick, onItemEventClick, onItemEventDoubleClick}: Props) {
    const [textures, setTextures] = useState<{ [key: string]: Texture } | null>(null);
    const itemTextureCache = new Map<string, Texture>();
    const SLOTS_WIDTH = storage.is_turtle ? 4 : 9;
    let clickTimeout: any = null;
    let lastTapTime = 0;

    useEffect(() => {
        const textures = {
            headerLeft: Assets.get('headerLeft'),
            headerSlot: Assets.get('headerSlot'),
            headerRight: Assets.get('headerRight'),

            slotLeft: Assets.get('slotLeft'),
            slot: Assets.get('slot'),
            slotEmpty: Assets.get('slotEmpty'),
            slotRight: Assets.get('slotRight'),

            footerLeft: Assets.get('footerLeft'),
            footerSlot: Assets.get('footerSlot'),
            footerRight: Assets.get('footerRight'),

            dirt: Assets.get('dirt'),
        };

        Object.values(textures).forEach(tex => {
            tex.source.style.scaleMode = 'nearest';
        });

        setTextures(textures);
    }, []);

    if (!textures) return null;

    const SLOTS_HEIGHT = Math.ceil(storage.slots_total / SLOTS_WIDTH);
    const BASE_HEIGHT = textures.slot.height;
    const SCALE = (18 * SLOTS_MULTIPLIER) / BASE_HEIGHT;


    function scaleToSlot() {
        return {x: SCALE, y: SCALE};
    }

    function scaledWidth(texture: Texture) {
        return texture.width * SCALE;
    }

    function scaledHeight(texture: Texture) {
        return texture.height * SCALE;
    }

    async function handleTap(slotIndex: number) {
        const now = Date.now();

        if (now - lastTapTime < DOUBLE_TAP_DELAY) {
            clearTimeout(clickTimeout);
            clickTimeout = null;

            await onSlotDoubleClick(slotIndex);
        } else {
            clickTimeout = setTimeout(async () => {
                await onSlotClick(slotIndex);
                clickTimeout = null;
            }, DOUBLE_TAP_DELAY);
        }

        lastTapTime = now;
    }



    async function onSlotClick(slot: number) {
        if (storage.items[slot]) {
            await onItemClick(slot);
        }

        if (onSlotEventClick) await onSlotEventClick(slot);
    }

    async function onItemClick(slot: number) {
        const item: StorageItem = storage.items[slot];
        if (onItemEventClick) await onItemEventClick(item, slot);
    }

    async function onSlotDoubleClick(slot: number) {
        if (storage.items[slot]) {
            await onItemDoubleClick(slot);
        }

        if (onSlotEventDoubleClick) await onSlotEventDoubleClick(slot);
    }

    async function onItemDoubleClick(slot: number) {
        const item: StorageItem = storage.items[slot];
        if (onItemEventDoubleClick) await onItemEventDoubleClick(item, slot);
    }

    const slotW = scaledWidth(textures.slot);
    const leftW = scaledWidth(textures.slotLeft);
    const headerH = scaledHeight(textures.headerSlot);
    const footerH = scaledHeight(textures.footerSlot);

    let currentY = 0;

    return (
        <Application
            width={18 * SLOTS_MULTIPLIER * SLOTS_WIDTH + (leftW * 2)}
            height={18 * SLOTS_MULTIPLIER * SLOTS_HEIGHT + headerH + footerH + 1}
            autoDensity={false}
            antialias={false}
            resolution={1}>
            <pixiContainer x={0} y={0}>

                {Array.from({length: SLOTS_HEIGHT}).map((_, rowIndex) => {
                    const isFirst = rowIndex === 0;
                    const isLast = rowIndex === SLOTS_HEIGHT - 1;

                    const slotY = isFirst ? (18 * SLOTS_MULTIPLIER) : 0;
                    const footerY = isFirst ? (18 * SLOTS_MULTIPLIER) * 2 : (18 * SLOTS_MULTIPLIER);

                    const headerY = slotY - headerH;

                    const row = (
                        <pixiContainer key={rowIndex} y={currentY} sortableChildren={true}>

                            {/* HEADER */}
                            {isFirst && (
                                <>
                                    <pixiSprite
                                        texture={textures.headerLeft}
                                        x={0}
                                        y={headerY}
                                        scale={scaleToSlot()}
                                        anchor={0}
                                    />

                                    {Array.from({length: SLOTS_WIDTH}).map((_, i) => (
                                        <pixiSprite
                                            key={'h' + i}
                                            texture={textures.headerSlot}
                                            x={leftW + i * slotW}
                                            y={headerY}
                                            scale={scaleToSlot()}
                                            anchor={0}
                                        />
                                    ))}

                                    <pixiSprite
                                        texture={textures.headerRight}
                                        x={leftW + SLOTS_WIDTH * slotW}
                                        y={headerY}
                                        scale={scaleToSlot()}
                                        anchor={0}
                                    />
                                </>
                            )}

                            {/* SLOT ROW */}
                            {(() => {
                                let x = 0;
                                const elements = [];

                                elements.push(
                                    <pixiSprite
                                        key="slot-left"
                                        texture={textures.slotLeft}
                                        x={x}
                                        y={slotY}
                                        scale={scaleToSlot()}
                                    />
                                );
                                x += leftW;

                                for (let col = 0; col < SLOTS_WIDTH; col++) {
                                    const slotIndex = rowIndex * SLOTS_WIDTH + col;
                                    const hasSlot = slotIndex < storage.slots_total;
                                    const isSelected = selectedSlot - 1 == slotIndex;
                                    const isTurtleSelected = storage.selected_slot != null && storage.selected_slot - 1 == slotIndex;

                                    if (hasSlot) {
                                        elements.push(
                                            <pixiSprite
                                                key={slotIndex}
                                                texture={textures.slot}
                                                x={x}
                                                y={slotY}
                                                interactive={true}
                                                eventMode="static"
                                                scale={scaleToSlot()}
                                                zIndex={0}
                                                onPointerTap={() => handleTap(slotIndex + 1)}
                                            />
                                        );
                                    } else {
                                        elements.push(
                                            <pixiSprite
                                                key={`empty-${rowIndex}-${col}`}
                                                texture={textures.slotEmpty}
                                                x={x}
                                                y={slotY}
                                                scale={scaleToSlot()}
                                                zIndex={0}
                                            />
                                        );
                                    }


                                    if (hasSlot) {
                                        const item = storage.items[slotIndex + 1];
                                        if (item) {
                                            elements.push(
                                                <ItemSlot item={item} textures={textures}
                                                          itemTextureCache={itemTextureCache} isSelected={isSelected}
                                                          SLOTS_MULTIPLIER={SLOTS_MULTIPLIER} x={x} y={slotY}
                                                          onPointerTap={() => handleTap(slotIndex + 1)}/>
                                            );
                                        }
                                    }

                                    if (isTurtleSelected) {
                                        elements.push(
                                            <pixiGraphics
                                                x={x}
                                                y={slotY}
                                                zIndex={5}
                                                draw={g => {
                                                    g.clear();
                                                    g.stroke({
                                                        width: SLOTS_MULTIPLIER,
                                                        color: 0xFFD700,
                                                        alpha: 1
                                                    });
                                                    g.rect(-2, -2, 18 * SLOTS_MULTIPLIER, 18 * SLOTS_MULTIPLIER);
                                                    g.stroke();
                                                }}
                                                onPointerTap={() => handleTap(slotIndex + 1)}
                                            />
                                        );
                                    }

                                    if (isSelected) {
                                        elements.push(
                                            <pixiGraphics
                                                x={x}
                                                y={slotY}
                                                zIndex={6}
                                                draw={g => {
                                                    g.clear();
                                                    g.fill({ color: 0x000000, alpha: 0.4 });
                                                    g.rect(0, 0, 17 * SLOTS_MULTIPLIER, 17 * SLOTS_MULTIPLIER);
                                                    g.fill();
                                                }}
                                                onPointerTap={() => handleTap(slotIndex + 1)}
                                            />
                                        );
                                    }

                                    x += slotW;
                                }

                                elements.push(
                                    <pixiSprite
                                        key="slot-right"
                                        texture={textures.slotRight}
                                        x={x}
                                        y={slotY}
                                        scale={scaleToSlot()}
                                    />
                                );

                                return elements;
                            })()}

                            {/* FOOTER */}
                            {isLast && (
                                <>
                                    <pixiSprite
                                        texture={textures.footerLeft}
                                        x={0}
                                        y={footerY}
                                        scale={scaleToSlot()}
                                    />

                                    {Array.from({length: SLOTS_WIDTH}).map((_, i) => (
                                        <pixiSprite
                                            key={'f' + i}
                                            texture={textures.footerSlot}
                                            x={leftW + i * slotW}
                                            y={footerY}
                                            scale={scaleToSlot()}
                                        />
                                    ))}

                                    <pixiSprite
                                        texture={textures.footerRight}
                                        x={leftW + SLOTS_WIDTH * slotW}
                                        y={footerY}
                                        scale={scaleToSlot()}
                                    />
                                </>
                            )}

                        </pixiContainer>
                    );

                    if (isFirst) currentY += (18 * SLOTS_MULTIPLIER) * 2;
                    else if (isLast) currentY += (18 * SLOTS_MULTIPLIER) * 2;
                    else currentY += (18 * SLOTS_MULTIPLIER);

                    return row;
                })}

            </pixiContainer>
        </Application>
    );
}
