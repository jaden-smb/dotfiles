-- Read pywal's generated colors as data; never execute a generated config.
-- Defaults allow Hyprland to start before the first `wal -i` invocation.
local colors = {
    active_border = "rgba(33ccffee)",
    inactive_border = "rgba(595959aa)",
}
local cache = os.getenv("XDG_CACHE_HOME") or (os.getenv("HOME") .. "/.cache")
local file = io.open(cache .. "/wal/colors-hyprland.conf", "r")
if file then
    for line in file:lines() do
        local index, value = line:match("^%s*%$color(%d+)%s*=%s*(.-)%s*$")
        if value and (value:match("^rgba%(%x%x%x%x%x%x%x%x%)$") or value:match("^rgb%(%x%x%x%x%x%x%)$")) then
            if index == "2" then colors.active_border = value end
            if index == "8" then colors.inactive_border = value end
        end
    end
    file:close()
end
return colors
