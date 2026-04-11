local dfpwm = require("cc.audio.dfpwm")
local decoder = dfpwm.make_decoder()

-- region { private }

local api = {}

local function drawProgress(current, total)
    local w, h = term.getSize()
    local barWidth = w - 2
    local filled = math.floor((current / total) * barWidth)

    term.setCursorPos(1, h)
    term.clearLine()
    term.write("[" .. string.rep("#", filled) .. string.rep("-", barWidth - filled) .. "]")
end

-- endregion

api.dfpwm = {}

function api.dfpwm.playFile(file_path)
    local speaker = peripheral.find("speaker")
    local handle = fs.open(file_path, "rb")

    while true do
        local chunk = handle.read(16 * 1024)
        if not chunk then break end

        local buffer = decoder(chunk)

        while not speaker.playAudio(buffer) do
            os.pullEvent("speaker_audio_empty")
        end
    end

    handle.close()
end

function api.dfpwm.playURL(url)
    local speaker = peripheral.find("speaker")
    local file = FrekOS.web.get(url)
	local chunk_size = 16 * 1024

	local chunks = {}
    for index = 1, #file, chunk_size do
        chunks[#chunks + 1] = file:sub(index, index + chunk_size - 1)
    end

	for index, chunk in pairs(chunks) do
		local buffer = decoder(chunk)

		while not speaker.playAudio(buffer) do
			os.pullEvent("speaker_audio_empty")
		end
	end
end

function api.dfpwm.playStream(stream)
    local speaker = peripheral.find("speaker")
	local chunk_size = 16 * 1024

	local chunks = {}
    for index = 1, #stream, chunk_size do
        chunks[#chunks + 1] = stream:sub(index, index + chunk_size - 1)
    end

    local total = #stream
    local played = 0

	for _, chunk in pairs(chunks) do
        played = played + #chunk
        drawProgress(played, total)

		local buffer = decoder(chunk)
		while not speaker.playAudio(buffer) do
			os.pullEvent("speaker_audio_empty")
		end
	end
end

local function beforeLoad()

end

local function afterLoad()

end

return api, beforeLoad, afterLoad
