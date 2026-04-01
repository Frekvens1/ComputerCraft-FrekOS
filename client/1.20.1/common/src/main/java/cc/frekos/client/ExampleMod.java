package cc.frekos.client;

import com.mojang.blaze3d.platform.InputConstants;
import dev.architectury.event.events.client.ClientGuiEvent;
import dev.architectury.registry.client.keymappings.KeyMappingRegistry;
import net.minecraft.client.KeyMapping;
import net.minecraft.client.Minecraft;
import java.nio.file.Path;

public final class ExampleMod {
    public static final String MOD_ID = "frekos_client";

    public static KeyMapping EXPORT_KEY;

    public static void init() {
        EXPORT_KEY = new KeyMapping(
                "key.frekos.icon.export",
                InputConstants.KEY_F7,
                "key.categories.misc"
        );

        KeyMappingRegistry.register(EXPORT_KEY);

        ClientGuiEvent.RENDER_HUD.register((gfx, delta) -> {
            if (EXPORT_KEY.consumeClick()) {
                Path exportDir = Minecraft.getInstance().gameDirectory.toPath()
                        .resolve("iconexporter/items");

                Minecraft.getInstance().setScreen(new ExportIcons(exportDir));
            }
        });
    }
}
