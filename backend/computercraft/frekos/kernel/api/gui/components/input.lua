local function input(params)
    local self = {
        fillColor = colors.white,
    }

    gui.components.super(self, params)

    self.onChangeFn = params.onChange
    local function onChange(app)
        if self.onChangeFn then
            self.onChangeFn(self, app, self.getText())
        end
    end

    local onClickSuper = self.onClick
    function self.onClick(app, x, y)
        onClickSuper(app, x, y)

        if x == nil or y == nil then
            return
        end

        self.cursorPosX = self.scrollOffsetX + x
        self.cursorPosY = y

        local text = self.getText()
        if self.cursorPosX > #text then
            self.cursorPosX = #text
        end
        if self.cursorPosX < 0 then
            self.cursorPosX = 0
        end
    end

    local eventSuper = self.event
    function self.event(event, app)
        eventSuper(event, app)
        term.setCursorBlink(self.isSelected)

        if event[1] == "key_up" then
            if keys.backspace == event[2] then
                if self.cursorPosX > 0 then
                    local text = self.getText()
                    self.setText(text:sub(1, self.cursorPosX - 1) .. text:sub(self.cursorPosX + 1))

                    self.cursorPosX = self.cursorPosX - 1
                    if self.cursorPosX < self.scrollOffsetX then
                        self.scrollOffsetX = math.max(0, self.cursorPosX - 1)
                    end

                    self.requestDraw = true
                    onChange(app)
                end

            elseif keys.delete == event[2] then
                local text = self.getText()
                if self.cursorPosX <= #text then
                    self.setText(text:sub(1, self.cursorPosX) .. text:sub(self.cursorPosX + 2))
                    self.requestDraw = true
                    onChange(app)
                end
            end

        elseif event[1] == "key" then
            if keys.left == event[2] then
                if self.cursorPosX > 0 then
                    self.cursorPosX = self.cursorPosX - 1
                end

                if self.cursorPosX < self.scrollOffsetX then
                    self.scrollOffsetX = self.cursorPosX
                end

                self.requestDraw = true

            elseif keys.right == event[2] then
                local text = self.getText()
                if self.cursorPosX < #text then
                    self.cursorPosX = self.cursorPosX + 1
                end

                if self.cursorPosX > self.scrollOffsetX + self.width then
                    self.scrollOffsetX = self.cursorPosX - self.width
                end

                self.requestDraw = true
            end

        elseif event[1] == "char" then
            local text = self.getText()
            local newText = text:sub(1, self.cursorPosX) ..
                    event[2] ..
                    text:sub(self.cursorPosX + 1)

            self.setText(newText)
            self.cursorPosX = self.cursorPosX + 1
            if self.cursorPosX > self.scrollOffsetX + self.width then
                self.scrollOffsetX = self.cursorPosX - self.width
            end

            self.requestDraw = true
            onChange(app)
        end
    end

    return self
end

return input
