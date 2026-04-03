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

        --print(event, key, x, y)
        for i = 1, #self.app.objects, 1 do
            self.app.objects[i].event(event)
        end

        if (event[1] ~= "mouse_click") then
            return nil
        end
        if (event[2] ~= 1) then
            return nil
        end

        for i = 1, #self.app.objects, 1 do
            if (self.app.objects[i].inside(event[3], event[4])) then
                self.app.objects[i].onClick(self.app)
            end
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
