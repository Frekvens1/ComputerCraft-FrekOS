trapdoor_side = "front"
websocket_url = "wss://frekos.cc/api/teleport"

function main()
    resetRedstone(trapdoor_side)
    ws = getWebsocket(websocket_url)

    while true do
        local msg = ws.receive(0.1)
        if msg then
            print("Server:", msg)
            toggleRedstone(trapdoor_side)
        end
    end
end

function getWebsocket(url)
    local ws, err = http.websocket(url)

    if not ws then
        print("Failed:", err)
        return nil
    end

    print("Connected!")
    return ws
end

function resetRedstone(side)
    redstone.setAnalogOutput(side, 15)
    os.sleep(0.1)
end

function toggleRedstone(side)
    redstone.setAnalogOutput(side, 0)
    os.sleep(1)
    redstone.setAnalogOutput(side, 15)
    os.sleep(0.1)
end

main()
