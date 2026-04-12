local function App(objects, onEvent)
    local self = {
        doRedraw = false,
        onEventFn = onEvent,
        objects = objects,
        backgroundColor = colors.cyan
    }

    function self.updateObjects(objects)
        self.objects = objects
        self.doRedraw = true
    end

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
