local function renderer(app)
    local self = {
        app = app
    }

    local function main()
        local ok, err = pcall(start)
        if not ok then
            backend.send({
                app = app,
                err = err,
            })
        end

        screen.clear()
    end

    function draw()
        term.setBackgroundColor(self.app.backgroundColor)
        term.clear()
    end

    function update()
        event = { os.pullEvent() }

        for i = 1, #self.app.objects, 1 do
            if event[1] == "mouse_click" then
                self.app.objects[i].isSelected = false
            end

            self.app.objects[i].event(event, app)
        end

        if self.app.onEventFn then
            self.app.onEventFn(event, app)
        end
    end

    function start()
        screen.clear()
        self.app.init()

        draw()

        while true do

            if self.app.doRedraw then
                draw()
                self.app.doRedraw = false
            end

            self.app.beforeRender()

            for i = 1, #self.app.objects, 1 do
                if self.app.objects[i].doDraw() then
                    self.app.objects[i].draw()
                end
            end

            self.app.afterRender()
            self.app.beforeUpdate()

            update()

            self.app.afterUpdate()
        end
    end

    main()
    return self
end

return renderer
