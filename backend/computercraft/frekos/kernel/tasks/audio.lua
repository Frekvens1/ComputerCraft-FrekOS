local dfpwm, decoder, speaker

local function playDFPWM(event)
    if event[1] == "frekos_audio_dfpwm_play" then
        if audio.dfpwm.current == nil then
            audio.dfpwm.current = audio.dfpwm.next
            audio.dfpwm.next = nil
        end

        if audio.dfpwm.current.chunk_index > #audio.dfpwm.current.chunks then
            if audio.dfpwm.current.should_loop then
                audio.dfpwm.current.chunk_index = 1
            else
                audio.dfpwm.current = nil
                os.queueEvent("frekos_audio_dfpwm_finished")
                return
            end
        end

        local chunk = audio.dfpwm.current.chunks[audio.dfpwm.current.chunk_index]
        local buffer = decoder(chunk)
        speaker.playAudio(buffer)

    elseif event[1] == "speaker_audio_empty" then
        if audio.dfpwm.next then
            audio.dfpwm.current = audio.dfpwm.next
            audio.dfpwm.next = nil
        else
            audio.dfpwm.current.chunk_index = audio.dfpwm.current.chunk_index + 1
        end

        os.queueEvent("frekos_audio_dfpwm_play")
    end
end

local function task()
    dfpwm = require("cc.audio.dfpwm")
    decoder = dfpwm.make_decoder()
    speaker = peripheral.find("speaker")

    while true do
        local event = { coroutine.yield() }

        if audio.dfpwm.current ~= nil or audio.dfpwm.next ~= nil then
            playDFPWM(event)
        end
    end
end

return task
