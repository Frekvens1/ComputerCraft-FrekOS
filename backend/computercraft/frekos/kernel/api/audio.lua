-- region { private }

local api = {
    dfpwm = {}
}

local chunk_size = 16 * 1024

-- endregion

function api.dfpwm.playStream(stream, should_loop)
    local chunks = {}
    for index = 1, #stream, chunk_size do
        chunks[#chunks + 1] = stream:sub(index, index + chunk_size - 1)
    end

    api.dfpwm.next = {}
    api.dfpwm.next.chunks = chunks
    api.dfpwm.next.chunk_index = 1
    api.dfpwm.next.should_loop = should_loop

    os.queueEvent("frekos_audio_dfpwm_play")
end

return api