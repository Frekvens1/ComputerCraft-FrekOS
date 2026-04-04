local label = gui.components.label
local button = gui.components.button

local orders = {}

function main()
    gui.render(gui.createApp(createObjects(), updateOrders))
end

function updateOrders(event, app)
    if event[1] ~= "frekos_restaurant" then
        return
    end

    if event[2] == "order" then
        table.insert(orders, {
            name = event[3],
            products = event[4]
        })

        app.objects = createObjects()

    elseif event[2] == "delete_order" then
        table.remove(orders, event[3])
        app.updateObjects(createObjects())
    end
end

function createObjects()
    local objects = {}

    local currentY = 1

    table.insert(objects, label({
        x = 2, y = currentY, width = term.getSize() - 3, height = 0,
        text = "Total orders: " .. #orders, fillColor = colors.cyan
    }))

    for index, order in ipairs(orders) do
        currentY = currentY + 2
        table.insert(objects, button({
            x = 2, y = currentY, width = term.getSize() - 3, height = 2,
            text = order.name .. " : Complete order", onClick = function(self, app, x, y)
                os.queueEvent("frekos_restaurant", "delete_order", index)
            end
        }))

        currentY = currentY + 3
        for product, count in pairs(order.products) do
            currentY = currentY + 1
            table.insert(objects, label({
                x = 2, y = currentY, width = term.getSize() - 3, height = 0,
                text = product .. " : " .. count, fillColor = colors.cyan
            }))
        end
    end

    return objects
end

main()