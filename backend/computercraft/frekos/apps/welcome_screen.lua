screen.saveColors()
local cursor_x, cursor_y = term.getCursorPos()
if cursor_y <= 2 then
    cursor_y = 3
end

term.setCursorPos(1, 1)

term.clearLine(1)

term.setTextColor(colors.orange)
term.write("FrekOS v0.1")

term.setTextColor(colors.gray)
term.write(" - ")

if backend.connection then
    term.setTextColor(colors.green)
    print("Online")
else
    term.setTextColor(colors.red)
    print("Offline")
end

term.setTextColor(colors.lightGray)
screen.printLine()

term.setCursorPos(cursor_x, cursor_y)
screen.restoreColors()
