local args = {...}
if #args == 0 then
    print("Error: No file specified")
    print("Usage: cat <file_path>")
    return nil
end

local file_path = args[1]
if not fs.exists(file_path) then
    print("Error: File doesn't exist")
    return nil
end

local dfpwm = require("cc.audio.dfpwm")
local speaker = peripheral.find("speaker")
local decoder = dfpwm.make_decoder()
local handle = fs.open(file_path, "rb")

print("Playing: " .. file_path)

while true do
    local chunk = handle.read(16 * 1024)
    if not chunk then break end

    local buffer = decoder(chunk)

    while not speaker.playAudio(buffer) do
        os.pullEvent("speaker_audio_empty")
    end
end

handle.close()
