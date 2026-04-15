local args = {...}

if #args == 0 then
    print("Error: No file specified")
    print("Usage: cat <file_path>")
    return nil
end

local file_path = args[1]
local cwd = shell.dir() or "/"
local resolved

if file_path:sub(1, 1) == "/" then
    resolved = file_path
else
    resolved = fs.combine(cwd, file_path)
end

if not fs.exists(resolved) then
    print("Error: File doesn't exist:", resolved)
    return nil
end

local handle = fs.open(resolved, "r")
local text = handle.readAll()
handle.close()

print(text)
return text
