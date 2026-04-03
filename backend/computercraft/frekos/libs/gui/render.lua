local function renderer(app)
    local self = {
        app = app
    }

    local function main()
        start()
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
    end

    function start()
        screen.clear()
        self.app.init()

        draw()

        while true do

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
