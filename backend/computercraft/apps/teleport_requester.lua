buttons = {}

function main()
    screenUtils.clear()
    refreshDevices()

    draw()

    while true do

        for i = 1, #buttons, 1 do
            if buttons[i].doDraw() then
                buttons[i].draw()
            end
        end

        update()
    end
end

function refreshDevices()
    local devices = FrekOS.api.device.getByType("teleport_module")
    local online_devices = FrekOS.api.device.getAllOnline()

    draw()

    buttons = {}
    for index, device in ipairs(devices) do
        if table.includes(online_devices, device.device_uuid) then
            table.insert(buttons,
                Button(2, ((index - 1) * 4) + 2, term.getSize() - 3, 2, device.name, function(self)
                    doTeleport(device.device_uuid)
                end)
        )
        end
    end
end

function doTeleport(device_uuid)
    FrekOS.api.device.events.teleport(device_uuid)
end

-- UI --

function Button(x, y, width, height, text, onClick)
    local self = {
        x = x,
        y = y,
        width = width,
        height = height,

        requestDraw = true,
        pressed = false,
        active = false,

        borderColor = colors.lightGray,
        fillColor = colors.lightGray,
        textColor = colors.black,

        text = text,
        onClickFn = onClick,
    }

    function self.onClick()
        if self.onClickFn then
            self.onClickFn(self)
        end
    end

    function self.inside(x, y)
        if ((x >= self.x) and (x <= self.width + self.x)) then
            if ((y >= self.y) and (y <= self.height + self.y)) then
                return true
            end
        end

        return false
    end

    function self.draw()

        paintutils.drawFilledBox(self.x, self.y, self.width + self.x, self.height + self.y, self.fillColor)
        paintutils.drawBox(self.x, self.y, self.width + self.x, self.height + self.y, self.borderColor)

        local center_x = math.ceil( (self.width / 2) - (string.len(self.text) / 2) + self.x )
        local center_y = (self.height / 2) + self.y

        term.setTextColor(self.textColor)
        term.setBackgroundColor(self.fillColor)
        term.setCursorPos(center_x, center_y)
        term.write(self.text)

        self.requestDraw = false

    end

    function self.event(event)

        if (event[1] == "mouse_up") then
            self.pressed = false
        end

        if (event[1] == "mouse_click") then
            self.pressed = false

            if (event[2] == 1) then
                if (self.inside(event[3], event[4])) then
                    if not self.active then
                        self.active = true
                        self.pressed = true
                        self.requestDraw = true

                        self.fillColor = colors.gray
                        self.borderColor = colors.gray
                    end
                end
            end
        end

        if not self.pressed then
            if self.active then
                self.active = false
                self.requestDraw = true

                self.fillColor = colors.lightGray
                self.borderColor = colors.lightGray
            end
        end
    end

    function self.doDraw()
        return self.requestDraw
    end

    function self.setText(text)
        self.text = text
    end

    function self.setBorderColor(borderColor)
        self.borderColor = borderColor
    end

    function self.setFillColor(fillColor)
        self.fillColor = fillColor
    end

    function self.setTextColor(textColor)
        self.textColor = textColor
    end

    return self
end

function draw()

    term.setBackgroundColor(colors.cyan)
    term.clear()

end

function update()

    event = { os.pullEvent() }

    --print(event, key, x, y)
    for i = 1, #buttons, 1 do
        buttons[i].event(event)
    end

    if (event[1] ~= "mouse_click") then
        return nil
    end
    if (event[2] ~= 1) then
        return nil
    end

    for i = 1, #buttons, 1 do
        if (buttons[i].inside(event[3], event[4])) then
            buttons[i].onClick()
        end
    end

end

main()
