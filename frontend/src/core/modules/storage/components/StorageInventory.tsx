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
} from 'pixi.js'
import {useEffect, useState} from 'react'
import type {Storage} from "@/core/modules/storage/models.ts";

extend({
    Container,
    Graphics,
    Sprite,
})

type Props = {
    storage: Storage;
};

const SLOTS_WIDTH = 9;
const SLOTS_SIZE = 64;

export function StorageInventory({storage}: Props) {
    const [textures, setTextures] = useState<{ [key: string]: Texture } | null>(null);

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
        };

        Object.values(textures).forEach(tex => {
            tex.source.style.scaleMode = 'nearest';
        });

        setTextures(textures);
    }, []);

    if (!textures) return null;

    const rows = Math.ceil(storage.slots_total / SLOTS_WIDTH);

    const BASE_HEIGHT = textures.slot.height;
    const SCALE = SLOTS_SIZE / BASE_HEIGHT;

    function scaleToSlot() {
        return {x: SCALE, y: SCALE};
    }

    function scaledWidth(tex: Texture) {
        return tex.width * SCALE;
    }

    function scaledHeight(tex: Texture) {
        return tex.height * SCALE;
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

                    const slotY = isFirst ? SLOTS_SIZE : 0;
                    const footerY = isFirst ? SLOTS_SIZE * 2 : SLOTS_SIZE;

                    const headerY = slotY - headerH;

                    const row = (
                        <pixiContainer key={rowIndex} y={currentY}>

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
                                        />
                                    );

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

                    if (isFirst) currentY += SLOTS_SIZE * 2;
                    else if (isLast) currentY += SLOTS_SIZE * 2;
                    else currentY += SLOTS_SIZE;

                    return row;
                })}

            </pixiContainer>
        </Application>
    );
}
