local function button(params)
    local self = {
        showBorder = true,
        textCentered = true
    }

    gui.components.super(self, params)

    return self
end

return button
