local function component(self, params)
    local function fallback(param, default)
        return orDefault(params[param], orDefault(self[param], default))
    end

    self.x = fallback("x", 0)
    self.y = fallback("y", 0)
    self.width = fallback("width", 0)
    self.height = fallback("height", 0)

    self.text = fallback("text", "")
    self.textColor = fallback("textColor", colors.black)
    self.textCentered = fallback("textCentered", false)
    self.cursorPosX = fallback("cursorPosX", #self.text)
    self.cursorPosY = fallback("cursorPosY", 0)
    self.scrollOffsetX = fallback("scrollOffsetX", 0)

    self.borderColorPressed = fallback("borderColorPressed", fallback("borderColor", colors.gray))
    self.fillColorPressed = fallback("fillColorPressed", fallback("fillColor", colors.gray))

    self.fillColor = fallback("fillColor", colors.lightGray)
    self.borderColor = fallback("borderColor", colors.lightGray)
    self.showBorder = fallback("showBorder", false)

    self.requestDraw = fallback("requestDraw", true)
    self.pressed = fallback("pressed", false)
    self.active = fallback("active", false)
    self.isSelected = fallback("isSelected", false)

    self.onClickFn = params.onClick

    self.activeFillColor = self.fillColor
    self.activeBorderColor = self.borderColor

    function self.draw()

        paintutils.drawFilledBox(self.x, self.y, self.width + self.x, self.height + self.y, self.activeFillColor)
        if self.showBorder then
            paintutils.drawBox(self.x, self.y, self.width + self.x, self.height + self.y, self.activeBorderColor)
        end

        term.setTextColor(self.getTextColor())
        term.setBackgroundColor(self.activeFillColor)

        local text = self.getText()
        local visible = text:sub(self.scrollOffsetX + 1, self.scrollOffsetX + self.width)

        if self.textCentered then
            local center_x = math.ceil((self.width / 2) - (#visible / 2) + self.x)
            local center_y = (self.height / 2) + self.y
            term.setCursorPos(center_x, center_y)
        else
            term.setCursorPos(self.x, self.y)
        end

        local cursorScreenX = self.x + (self.cursorPosX - self.scrollOffsetX)

        term.write(visible)
        term.setCursorPos(cursorScreenX, self.y + self.cursorPosY)

        self.requestDraw = false

    end

    function self.event(event, app)
        if event[1] == "mouse_up" then
            self.pressed = false
            if self.inside(event[3], event[4]) then
                self.onClick(app, event[3] - self.x, event[4] - self.y)
            end
        end

        if self.isSelected and event[1] == "key_up" and table.includes({keys.enter, keys.numPadEnter}, event[2]) then
            self.pressed = false
            self.onClick(app, nil, nil)
        end

        if event[1] == "mouse_click" then
            self.pressed = false

            if event[2] == 1 then
                if self.inside(event[3], event[4]) then
                    if not self.active then
                        self.active = true
                        self.pressed = true
                        self.requestDraw = true
                        self.isSelected = true

                        self.activeFillColor = self.getFillColorPressed()
                        self.activeBorderColor = self.getBorderColorPressed()
                    end
                end
            end
        end

        if self.isSelected and event[1] == "key" and table.includes({keys.enter, keys.numPadEnter}, event[2]) then
            if not self.active then
                self.active = true
                self.pressed = true
                self.requestDraw = true

                self.activeFillColor = self.getFillColorPressed()
                self.activeBorderColor = self.getBorderColorPressed()
            end
        end

        if not self.pressed then
            if self.active then
                self.active = false
                self.requestDraw = true

                self.activeFillColor = self.getFillColor()
                self.activeBorderColor = self.getBorderColor()
            end
        end
    end

    -- common

    function self.onClick(app, x, y)
        if self.onClickFn then
            self.onClickFn(self, app, x, y)
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

    function self.doDraw()
        return self.requestDraw
    end

    -- setters

    function self.setText(text)
        self.text = text
    end

    function self.setBorderColor(borderColor)
        self.borderColor = borderColor
    end

    function self.setFillColor(fillColor)
        self.fillColor = fillColor
    end

    function self.setBorderColorPressed(borderColor)
        self.borderColorPressed = borderColor
    end

    function self.setFillColorPressed(fillColor)
        self.fillColorPressed = fillColor
    end

    function self.setTextColor(textColor)
        self.textColor = textColor
    end

    -- getters

    function self.getText()
        return orDefault(self.text, "")
    end

    function self.getBorderColor()
        return orDefault(self.borderColor, colors.lightGray)
    end

    function self.getFillColor()
        return orDefault(self.fillColor, colors.lightGray)
    end

    function self.getBorderColorPressed()
        return orDefault(self.borderColorPressed, orDefault(self.fillColor, colors.gray))
    end

    function self.getFillColorPressed()
        return orDefault(self.fillColorPressed, orDefault(self.fillColor, colors.gray))
    end

    function self.getTextColor()
        return orDefault(self.textColor, colors.black)
    end
end

return component
