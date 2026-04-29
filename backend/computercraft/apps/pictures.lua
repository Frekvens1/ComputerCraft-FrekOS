local mon = peripheral.find("monitor")
if not mon then error("No monitor found") end
mon.setTextScale(0.5)
mon.clear()

local button = gui.components.button

function main()
    gui.render(gui.createApp(picturePage()))
end

function picturePage()
    local objects = {}

    local pictures = backend.api.pictures.getAll()
    for index, picture in ipairs(pictures) do
        table.insert(objects, button({
            x = 2, y = 4 * (index - 1) + 2, width = term.getSize() - 3, height = 2,
            text = picture.name, onClick = function(self, app, x, y)
                displayPicture(picture.picture_uuid)
            end
        }))
    end

    return objects
end

function displayPicture(picture_uuid)
    local img_raw = backend.api.pictures.getBimg(picture_uuid)
    local img = textutils.unserialize(img_raw)

    local frame = img[1]

    -- Apply palette from the frame (NOT img.palette)
    if frame.palette then
        for i = 0, #frame.palette do
            local c = frame.palette[i]
            if type(c) == "table" then
                mon.setPaletteColor(2^i, table.unpack(c))
            else
                mon.setPaletteColor(2^i, c)
            end
        end
    end

    -- Draw frame
    for y, row in ipairs(frame) do
        mon.setCursorPos(1, y)
        mon.blit(row[1], row[2], row[3])
    end
end

main()
