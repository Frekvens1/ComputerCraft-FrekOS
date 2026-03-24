local args = {...}
if #args == 0 then
    print("Error: No file specified")
    print("Usage: cat <file_path>")
    return nil
end

local file_path = args[1]
if fs.exists(file_path) then
    local text = fileUtils.read(file_path)
    print(text)
    return text
else
    print("Error: File doesn't exist")
    return nil
end
