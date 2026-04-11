local button = gui.components.button

function main()
    gui.render(gui.createApp(musicPage()))
end

function musicPage()
    local objects = {}

    local songs = FrekOS.api.music.dfpwm.getAll()
    for index, song in ipairs(songs) do
        table.insert(objects, button({
            x = 2, y = 4 * (index - 1) + 2, width = term.getSize() - 3, height = 2,
            text = song.name, onClick = function(self, app, x, y)
                parallel.waitForAny(function()
                    local event = {os.pullEventRaw("mouse_click")}
                    os.queueEvent(table.unpack(event))
                end, function()
                    while true do
                        playStream(song.dfpwm_uuid)
                    end
                end)
            end
        }))
    end

    return objects
end

function playStream(dfpwm_uuid)
    audioUtils.dfpwm.playStream(FrekOS.api.music.dfpwm.getStream(dfpwm_uuid))
end

main()
