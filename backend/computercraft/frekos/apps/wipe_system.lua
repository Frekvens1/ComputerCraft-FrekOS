local function wipeRoot()
    for _, item in ipairs(fs.list("/")) do
        if item ~= "rom" and item ~= "disk" then
            fs.delete("/" .. item)
        end
    end
end

print("Wiping system (excluding ROM and disk)...")
wipeRoot()
print("Done.")
