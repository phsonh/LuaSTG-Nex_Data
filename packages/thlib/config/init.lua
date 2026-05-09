local M = {}

local function read_file(path)
    local f, err = io.open(path, "rb")

    if not f then
        return nil, err
    end

    local text = f:read("*a")
    f:close()

    return text
end

local function require_json()
    local ok, json = pcall(require, "cjson.safe")
    if ok and json then
        return json
    end

    ok, json = pcall(require, "cjson")
    if ok and json then
        return json
    end

    if _G.cjson then
        return _G.cjson
    end

    error("Config: cannot find cjson module", 2)
end

local json = require_json()

local function decode_json(text, path)
    if json.decode then
        local ok, result = pcall(json.decode, text)

        if ok and result ~= nil then
            return result
        end

        error("Config: failed to decode json '" .. tostring(path) .. "': " .. tostring(result), 2)
    end

    error("Config: json decoder has no decode function", 2)
end

local function is_array(t)
    if type(t) ~= "table" then
        return false
    end

    local n = 0

    for k, _ in pairs(t) do
        if type(k) ~= "number" then
            return false
        end

        if k > n then
            n = k
        end
    end

    return n > 0
end

local function deep_copy(v)
    if type(v) ~= "table" then
        return v
    end

    local out = {}

    for k, value in pairs(v) do
        out[k] = deep_copy(value)
    end

    return out
end

local function deep_merge(dst, src)
    if type(src) ~= "table" then
        return dst
    end

    for k, v in pairs(src) do
        if type(v) == "table"
            and type(dst[k]) == "table"
            and not is_array(v)
            and not is_array(dst[k])
        then
            deep_merge(dst[k], v)
        else
            dst[k] = deep_copy(v)
        end
    end

    return dst
end

local function dirname(path)
    local dir = path:match("^(.*)[/\\][^/\\]*$")

    if dir == nil or dir == "" then
        return "."
    end

    return dir
end

local function join_path(base, path)
    if path:match("^%a:[/\\]") or path:match("^[/\\]") then
        return path
    end

    if base == "." then
        return path
    end

    return base .. "/" .. path
end

local function load_json_file(path, seen)
    seen = seen or {}

    if seen[path] then
        error("Config: circular include detected: " .. tostring(path), 2)
    end

    seen[path] = true

    local text, err = read_file(path)

    if not text then
        error("Config: cannot read '" .. tostring(path) .. "': " .. tostring(err), 2)
    end

    local cfg = decode_json(text, path)
    local base_dir = dirname(path)

    local includes = cfg.include
    cfg.include = nil

    if type(includes) == "table" then
        for _, item in ipairs(includes) do
            local include_path
            local optional = false

            if type(item) == "string" then
                include_path = item
            elseif type(item) == "table" then
                include_path = item.path
                optional = item.optional == true
            end

            if include_path then
                local full_path = join_path(base_dir, include_path)
                local include_text = read_file(full_path)

                if include_text then
                    local include_cfg = load_json_file(full_path, seen)
                    deep_merge(cfg, include_cfg)
                elseif not optional then
                    error("Config: missing required include '" .. tostring(full_path) .. "'", 2)
                end
            end
        end
    end

    seen[path] = nil

    return cfg
end

function M.Load(path)
    path = path or "config.json"

    local cfg = load_json_file(path)

    M.current = cfg

    return cfg
end

function M.Get(path, default)
    local cur = M.current

    if type(path) ~= "string" or path == "" then
        return cur or default
    end

    for key in path:gmatch("[^%.]+") do
        if type(cur) ~= "table" then
            return default
        end

        cur = cur[key]
    end

    if cur == nil then
        return default
    end

    return cur
end

function M.ExportSetting(cfg)
    cfg = cfg or M.current or {}

    local graphics = cfg.graphics_system or {}
    local timing = cfg.timing or {}
    local audio = cfg.audio_system or {}
    local window = cfg.window or {}

    _G.setting = _G.setting or {}

    setting.resx = graphics.width or setting.resx or 640
    setting.resy = graphics.height or setting.resy or 480

    setting.windowed = not (graphics.fullscreen == true)
    setting.fullscreen = graphics.fullscreen == true
    setting.vsync = graphics.vsync ~= false

    setting.fps = timing.frame_rate or setting.fps or 60

    setting.title = window.title or setting.title or "LuaSTG-Nex"

    setting.sevolume = audio.sound_effect_volume or setting.sevolume or 1.0
    setting.bgmvolume = audio.music_volume or setting.bgmvolume or 1.0

    return setting
end

function M.ApplyEngine(cfg)
    cfg = cfg or M.current or {}

    local s = M.ExportSetting(cfg)

    if lstg.SetTitle then
        lstg.SetTitle(s.title)
    end

    if lstg.SetWindowed then
        lstg.SetWindowed(s.windowed)
    end

    if lstg.SetResolution then
        lstg.SetResolution(s.resx, s.resy)
    end

    if lstg.SetFPS then
        lstg.SetFPS(s.fps)
    end

    if lstg.SetVsync then
        lstg.SetVsync(s.vsync)
    end

    if lstg.SetSEVolume then
        lstg.SetSEVolume(s.sevolume)
    end

    if lstg.SetBGMVolume then
        lstg.SetBGMVolume(s.bgmvolume)
    end

    return s
end

function M.PrintSummary()
    local s = _G.setting or {}

    local msg = string.format(
        "[config] title=%s res=%dx%d windowed=%s vsync=%s fps=%s se=%.2f bgm=%.2f",
        tostring(s.title),
        tonumber(s.resx) or 0,
        tonumber(s.resy) or 0,
        tostring(s.windowed),
        tostring(s.vsync),
        tostring(s.fps),
        tonumber(s.sevolume) or 0,
        tonumber(s.bgmvolume) or 0
    )

    if lstg and lstg.Log then
        lstg.Log(2, msg)
    elseif print then
        print(msg)
    end
end

return M