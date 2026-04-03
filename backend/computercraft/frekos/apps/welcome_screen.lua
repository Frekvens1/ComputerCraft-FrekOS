screen.clear()
screen.saveColors()

term.setTextColor(colors.orange)
term.write("FrekOS v0.1")

term.setTextColor(colors.gray)
term.write(" - ")

if backendUtils.connection then
    term.setTextColor(colors.green)
    print("Online")
else
    term.setTextColor(colors.red)
    print("Offline")
end

term.setTextColor(colors.lightGray)
screen.printLine()

screen.restoreColors()
