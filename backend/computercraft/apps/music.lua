local song_index = 1
local songs = FrekOS.api.music.dfpwm.getAll()
local loop_songs = true

FrekOS.events.addTask("frekos_music", function(event)
    if event[1] == "char" and event[2] == "a" then
        song_index = song_index - 1
    elseif event[1] == "key_up" and event[2] == 263 then
        song_index = song_index - 1 -- Arrow left
    elseif event[1] == "char" and event[2] == "d" then
        song_index = song_index + 1
    elseif event[1] == "key_up" and event[2] == 262 then
        song_index = song_index + 1 -- Arrow right
    end
end)

while loop_songs do
    if (song_index > #songs) then
        song_index = 1
    end

    song = songs[song_index]

    screenUtils.clear()

    print("Now playing:")
    screenUtils.printLine()
    print(song.name)

    -- TODO: Add coroutines so we can change music
    audioUtils.dfpwm.playStream(FrekOS.api.music.dfpwm.getStream(song.dfpwm_uuid))
end

screenUtils.clear()
FrekOS.events.removeTask("frekos_music")
