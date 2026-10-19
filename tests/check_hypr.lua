package.path = './config/hypr/?.lua;' .. package.path
local binds, monitors, workspaces, animations, curves, rules, layers, events, config = {}, {}, {}, {}, {}, {}, {}, {}, {}
local executed = {}
local function dispatcher(name)
    return function(args) return { name = name, args = args } end
end
hl = {
    dsp = {
        exec_cmd = dispatcher('exec'), focus = dispatcher('focus'), layout = dispatcher('layout'),
        window = {}, workspace = { toggle_special = dispatcher('special') },
    },
    bind = function(key, action, flags)
        assert(not binds[key], 'Duplicate bind: '..key)
        binds[key] = {action = action, flags = flags or {}}
    end,
    monitor = function(t) assert(type(t.output)=='string'); monitors[#monitors+1] = t end,
    workspace_rule = function(t) workspaces[t.workspace] = t end,
    env = function(k,v) assert(type(k)=='string' and type(v)=='string') end,
    permission = function(t) assert(t.binary and t.type and t.mode) end,
    config = function(t) for k,v in pairs(t) do config[k] = v end end,
    device = function(t) assert(t.name and t.sensitivity == -0.5) end,
    gesture = function(t) assert(t.fingers == 3 and t.action == 'workspace') end,
    curve = function(name,t) curves[name] = t end,
    animation = function(t)
        assert(t.bezier == 'default' or curves[t.bezier], 'Missing bezier: '..tostring(t.bezier))
        assert(t.enabled and t.speed > 0)
        animations[#animations+1] = t
    end,
    window_rule = function(t) assert(t.match); rules[#rules+1] = t end,
    layer_rule = function(t) assert(t.match.namespace); layers[#layers+1] = t end,
    on = function(name,callback) events[name] = callback end,
    exec_cmd = function(cmd) executed[#executed+1] = cmd end,
}
for _,name in ipairs({'close','float','pseudo','fullscreen','move','drag','resize'}) do
    hl.dsp.window[name] = dispatcher(name)
end
assert(loadfile('config/hypr/hyprland.lua'))()
local count = 0
for _,_ in pairs(binds) do count = count + 1 end
assert(count == 57, 'Unexpected bind count: '..count)
assert(#monitors == 2 and monitors[1].scale == 1.33 and monitors[2].position == '1440x0')
for i=1,9 do assert(workspaces[tostring(i)].monitor == (i<=3 and 'eDP-1' or 'HDMI-A-1')) end
assert(workspaces['1'].default and workspaces['4'].default)
for i=1,10 do
    local key = tostring(i%10)
    assert(binds['SUPER + '..key].action.args.workspace == tostring(i))
    assert(binds['SUPER + SHIFT + '..key].action.args.follow == true)
end
assert(binds['SUPER + SHIFT + S'].action.args.workspace == 'special:magic')
assert(binds['SUPER + mouse:272'].flags.mouse)
assert(binds['XF86AudioRaiseVolume'].flags.locked and binds['XF86AudioRaiseVolume'].flags.repeating)
assert(binds['XF86AudioPlay'].flags.locked and not binds['XF86AudioPlay'].flags.repeating)
assert(config['cursor.no_hardware_cursors'] == 2)
assert(config['input.kb_variant'] == 'intl,')
assert(config['dwindle.pseudotile'] == nil)
assert(#animations == 17 and #rules == 13 and #layers == 4)
assert(#executed == 0, 'Autostart executed on config load/reload')
events['hyprland.start']()
assert(#executed == 7)
assert(executed[2] == 'pgrep -x waybar >/dev/null || waybar')
local expected_active = os.getenv('TEST_ACTIVE') or 'rgba(33ccffee)'
assert(config['general.col.active_border'] == expected_active)
assert(config['general.col.inactive_border'] == (os.getenv('TEST_INACTIVE') or 'rgba(595959aa)'))
print('Passed: Lua module execution, 57 bindings, monitors/workspaces, animation curves, rules, startup timing and palette')
