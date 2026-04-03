local function App(objects)
    local self = {
        objects = objects,
        backgroundColor = colors.cyan
    }

    function self.init()
        -- Override this for startup code
    end

    function self.beforeRender()

    end

    function self.afterRender()

    end

    function self.beforeUpdate()

    end

    function self.afterUpdate()

    end

    return self
end

return App
