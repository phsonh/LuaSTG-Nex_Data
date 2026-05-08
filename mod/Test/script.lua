circle_unit = Class(Unit)

function circle_unit:init()
    
end

function circle_unit:frame()

end

function circle_unit:after_frame()

end

New(circle_unit)

for k, v in pairs(lstg) do
    local s = tostring(k)
    if s:find("Load") or s:find("Image") or s:find("Texture") or s:find("Sprite") then
        Console.Log("[lstg api] " .. s .. " = " .. tostring(v))
    end
end