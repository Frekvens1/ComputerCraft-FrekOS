local input = gui.components.input
local button = gui.components.button

local kitchen_device = "a0bfab0b-61b6-4470-80fc-98981456e57f"

local products = {
    "Chicken sausage", "Pork nuckle",
    "Wheat beer", "Hops beer"
}

local orderName = "Name"
local currentOrder = {}

function main()
    gui.render(gui.createApp(orderPage()))
end

function getCount(product)
    if currentOrder[product] == nil then
        return 0
    end

    return currentOrder[product]
end

function getProductText(product)
    return product .. " " .. tostring(getCount(product))
end

function orderPage()
    local objects = {}

    table.insert(objects, input({
        x = 2, y = 2, width = term.getSize() - 3, height = 0,
        text = orderName, onChange = function(self, app, text)
            orderName = text
        end
    }))

    for index, product in ipairs(products) do
        table.insert(objects, button({
            x = 2, y = 4 * (index), width = term.getSize() - 7, height = 2,
            text = getProductText(product), onClick = function(self, app, x, y)
                if currentOrder[product] == nil then
                    currentOrder[product] = 0
                end

                currentOrder[product] = currentOrder[product] + 1

                app.objects[index * 2].text = getProductText(product)
                app.objects[index * 2].requestDraw = true
            end
        }))

        table.insert(objects, button({
            x = term.getSize() - 3, y = 4 * (index), width = 2, height = 2,
            text = "-", onClick = function(self, app, x, y)
                if currentOrder[product] == nil then
                    currentOrder[product] = 0
                end

                if currentOrder[product] > 0 then
                    currentOrder[product] = currentOrder[product] - 1
                    app.objects[index * 2].text = getProductText(product)
                    app.objects[index * 2].requestDraw = true
                end
            end
        }))
    end

    table.insert(objects, button({
        x = 2, y = 20, width = term.getSize() - 3, height = 0,
        text = "Send", onClick = function(self, app, x, y)
            if table.length(currentOrder) == 0 then
                return
            end

            sendOrder(currentOrder)

            app.objects[1].text = "Name"
            app.objects[1].requestDraw = true

            orderName = "Name"
            currentOrder = {}

            for index, product in ipairs(products) do
                app.objects[index * 2].text = getProductText(product)
                app.objects[index * 2].requestDraw = true
            end
        end
    }))

    return objects
end

function sendOrder(order)
    FrekOS.api.device.events.raw(kitchen_device, {
        "frekos_restaurant", "order", orderName, order
    })
end

main()
