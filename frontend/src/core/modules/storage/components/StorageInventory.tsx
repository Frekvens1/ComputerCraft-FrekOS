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
import type {Storage} from "@/core/modules/storage/models.ts";
import {ItemSlot} from "@/core/modules/storage/components/ItemSlot.tsx";

extend({
    Container,
    Graphics,
    Sprite,
    Text,
})

type Props = {
    storage: Storage;
};

const SLOTS_WIDTH = 9;
const SLOTS_MULTIPLIER = 4;

export function StorageInventory({storage}: Props) {
    const [textures, setTextures] = useState<{ [key: string]: Texture } | null>(null);
    const itemTextureCache = new Map<string, Texture>();

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

    const rows = Math.ceil(storage.slots_total / SLOTS_WIDTH);
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

    const slotW = scaledWidth(textures.slot);
    const leftW = scaledWidth(textures.slotLeft);
    const headerH = scaledHeight(textures.headerSlot);

    let currentY = 0;

    return (
        <Application
            width={800}
            height={600}
            autoDensity={false}
            antialias={false}
            resolution={1}>
            <pixiContainer x={0} y={0}>

                {Array.from({length: rows}).map((_, rowIndex) => {
                    const isFirst = rowIndex === 0;
                    const isLast = rowIndex === rows - 1;

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

                                    elements.push(
                                        <pixiSprite
                                            key={hasSlot ? slotIndex : `empty-${rowIndex}-${col}`}
                                            texture={hasSlot ? textures.slot : textures.slotEmpty}
                                            x={x}
                                            y={slotY}
                                            scale={scaleToSlot()}
                                            zIndex={0}
                                        />
                                    );

                                    if (hasSlot) {
                                        const item = storage.items[slotIndex + 1];
                                        if (item) {
                                            elements.push(
                                                <ItemSlot item={item} textures={textures}
                                                          itemTextureCache={itemTextureCache}
                                                          SLOTS_MULTIPLIER={SLOTS_MULTIPLIER} x={x} y={slotY}/>
                                            );
                                        }
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
