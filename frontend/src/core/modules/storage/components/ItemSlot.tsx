import {Assets, Texture} from "pixi.js";
import {useEffect, useState} from "react";
import type {StorageItem} from "@/core/modules/storage/models.ts";

export function ItemSlot({x, y, SLOTS_MULTIPLIER, item, textures, itemTextureCache}: {
    x: number;
    y: number;
    SLOTS_MULTIPLIER: number;
    item: StorageItem;
    textures: { [key: string]: Texture };
    itemTextureCache: Map<string, Texture>;
}) {
    const item_path = item?.name.replace(/:/, '/');
    const item_url = item ? `/items/${item_path}.png` : null;
    const texture = useItemTexture(item_url);

    function useItemTexture(url: string | null) {
        const [texture, setTexture] = useState<Texture | null>(null);

        useEffect(() => {
            if (!url) return;

            let mounted = true;

            loadItemTexture(url).then(tex => {
                if (mounted) setTexture(tex);
            });

            return () => {
                mounted = false;
            };
        }, [url]);

        return texture;
    }

    async function loadItemTexture(url: string): Promise<Texture> {
        if (itemTextureCache.has(url)) {
            return itemTextureCache.get(url)!;
        }

        try {
            const tex = await Assets.load(url);
            tex.source.style.scaleMode = 'nearest';
            itemTextureCache.set(url, tex);
            return tex;
        } catch {
            console.warn("Missing item texture:", url);
            return Assets.get("missingTexture"); // fallback
        }
    }

    function scaleItem(texture: Texture) {
        const BASE_HEIGHT = texture.height;
        const SCALE = (16 * SLOTS_MULTIPLIER) / BASE_HEIGHT;

        return {x: SCALE, y: SCALE};
    }

    const slotCount = (
        <pixiText
            text={String(item.count)}
            x={x + SLOTS_MULTIPLIER / 2 + (SLOTS_MULTIPLIER * 17)}
            y={y + SLOTS_MULTIPLIER / 2 + (SLOTS_MULTIPLIER * 17)}
            anchor={1}
            style={{
                fill: "white",
                fontSize: 9 * SLOTS_MULTIPLIER,
                fontFamily: "Monocraft",
                fontWeight: "bold",
                stroke: "black",
            }}
            zIndex={2}
        />
    )

    if (texture) {
        return (
            <>
                <pixiSprite
                    texture={texture}
                    x={x + SLOTS_MULTIPLIER}
                    y={y + SLOTS_MULTIPLIER}
                    scale={scaleItem(texture)}
                    zIndex={1}
                />

                {item.count > 1 && slotCount}
            </>
        );
    } else {
        return (
            <>
                <pixiSprite
                    texture={textures.dirt}
                    x={x + SLOTS_MULTIPLIER}
                    y={y + SLOTS_MULTIPLIER}
                    scale={scaleItem(textures.dirt)}
                    zIndex={1}
                />

                {item.count > 1 && slotCount}
            </>
        );
    }
}
