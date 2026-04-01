package cc.frekos.client;

import com.mojang.blaze3d.platform.NativeImage;
import com.mojang.blaze3d.platform.Window;
import com.mojang.blaze3d.vertex.PoseStack;
import net.minecraft.client.Minecraft;
import net.minecraft.client.gui.GuiGraphics;
import net.minecraft.client.gui.screens.Screen;
import net.minecraft.network.chat.Component;
import net.minecraft.resources.ResourceLocation;
import net.minecraft.world.item.Item;
import net.minecraft.world.item.ItemStack;
import net.minecraft.core.registries.BuiltInRegistries;
import org.lwjgl.opengl.GL11;
import org.lwjgl.system.MemoryUtil;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

public class ExportIcons extends Screen {

    private int index = 0;
    private final Path exportDir;
    private final List<Item> items;

    final int ICON_SIZE = 256;
    final float scale = ICON_SIZE / 16f;

    public ExportIcons(Path exportDir) {
        super(Component.literal("Exporting Item Icons..."));
        this.items = BuiltInRegistries.ITEM.stream().toList();
        this.exportDir = exportDir;
    }

    public static void saveImage(NativeImage image, Path path) {
        try {
            Files.createDirectories(path.getParent());
            image.writeToFile(path);
        } catch (IOException e) {
            throw new RuntimeException("Failed to save image: " + path, e);
        }
    }


    @Override
    public void render(GuiGraphics gfx, int mouseX, int mouseY, float delta) {
        super.render(gfx, mouseX, mouseY, delta);

        Minecraft mc = Minecraft.getInstance();

        String text = "Exporting " + index + " / " + items.size();
        gfx.drawString(mc.font, text, ICON_SIZE + 10, 10, 0xFFFFFF);

        if (index >= items.size()) {
            mc.setScreen(null);
            return;
        }

        Item item = items.get(index);
        ItemStack stack = new ItemStack(item);

        gfx.fill(0, 0, ICON_SIZE, ICON_SIZE, 0xFFFF00FF);

        PoseStack pose = gfx.pose();
        pose.pushPose();

        pose.scale(scale, scale, 1f);
        gfx.renderItem(stack, 0, 0);
        pose.popPose();

        NativeImage img = captureRegion(0, 0, ICON_SIZE, ICON_SIZE);

        removeBackground(img);

        ResourceLocation id = BuiltInRegistries.ITEM.getKey(item);
        Path output = exportDir
                .resolve(id.getNamespace())
                .resolve(id.getPath() + ".png");

        saveImage(img, output);


        index++;
    }

    public static NativeImage captureRegion(int guiX, int guiY, int guiW, int guiH) {
        Minecraft mc = Minecraft.getInstance();
        Window window = mc.getWindow();

        double scale = window.getGuiScale();

        int fbX = (int) (guiX * scale);
        int fbY = (int) ((window.getGuiScaledHeight() - guiY - guiH) * scale);
        int fbW = (int) (guiW * scale);
        int fbH = (int) (guiH * scale);

        long buffer = MemoryUtil.nmemAlloc((long) fbW * fbH * 4);

        GL11.glReadPixels(
                fbX, fbY,
                fbW, fbH,
                GL11.GL_RGBA,
                GL11.GL_UNSIGNED_BYTE,
                buffer
        );

        NativeImage result = new NativeImage(guiW, guiH, true);

        for (int y = 0; y < guiH; y++) {
            for (int x = 0; x < guiW; x++) {
                int srcX = (int) (x * scale);
                int srcY = (int) (y * scale);

                long index = ((long) srcY * fbW + srcX) * 4;

                int r = MemoryUtil.memGetByte(buffer + index) & 0xFF;
                int g = MemoryUtil.memGetByte(buffer + index + 1) & 0xFF;
                int b = MemoryUtil.memGetByte(buffer + index + 2) & 0xFF;
                int a = MemoryUtil.memGetByte(buffer + index + 3) & 0xFF;

                int color = (a << 24) | (b << 16) | (g << 8) | r;
                result.setPixelRGBA(x, guiH - 1 - y, color);
            }
        }

        MemoryUtil.nmemFree(buffer);
        return result;
    }

    public static void removeBackground(NativeImage img) {
        int w = img.getWidth();
        int h = img.getHeight();

        for (int y = 0; y < h; y++) {
            for (int x = 0; x < w; x++) {
                int color = img.getPixelRGBA(x, y);

                int r = color & 0xFF;
                int g = (color >> 8) & 0xFF;
                int b = (color >> 16) & 0xFF;

                if (r == 255 && g == 0 && b == 255) {
                    img.setPixelRGBA(x, y, 0x00000000);
                }
            }
        }
    }

}
