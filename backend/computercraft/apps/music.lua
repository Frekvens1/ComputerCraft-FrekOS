local songs = FrekOS.api.music.dfpwm.getAll()
for index, song in ipairs(songs) do
    screenUtils.clear()

    print("Now playing:")
    screenUtils.printLine()
    print(song.name)

    audioUtils.dfpwm.playStream(FrekOS.api.music.dfpwm.getStream(song.dfpwm_uuid))
end

screenUtils.clear()
