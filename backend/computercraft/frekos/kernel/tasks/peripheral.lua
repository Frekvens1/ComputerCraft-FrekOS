local function task()
    while true do
        local event = { coroutine.yield() }

        if event[1] == "speaker_audio_empty" then

        end
    end
end

return task
