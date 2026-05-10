Debug.Print("[mod/Test] script.lua loaded")

Resource.Image.LoadTexture("tex.ball", "ball_huge_blue.png")
Resource.Image.LoadFullSprite("img.ball", "tex.ball", 1, 1)

Resource.Image.LoadTexture("tex.grain_a", "grain_a.png")
Resource.Image.LoadFullSprite("grain_a", "tex.grain_a")

Resource.Image.LoadTexture("tex.fog", "fog.png")
Resource.Image.LoadFullSprite("fog", "tex.fog",0.5,0.5)

local DEG = math.pi / 180

local function cosd(a)
    return math.cos(a * DEG)
end

local function sind(a)
    return math.sin(a * DEG)
end


local function lerp(a, b, t)
    return a + (b - a) * t
end

-- ============================================================
-- Bullet
-- ============================================================

bullet_body_ani = Class(Ani)

function bullet_body_ani:init(master, visual)
    Ani.init(self, master, visual)

    self.img = "grain_a"
    self.blend = ""
    self.a = 255
    self.r = 255
    self.g = 255
    self.b = 255
    self.scale_x = 1
    self.scale_y = 1
    self.z = 0.5
    self.layer = Visual.Layer.ENEMY_BULLET
end

function bullet_body_ani:frame()
    self.x = self.master.x
    self.y = self.master.y
    self.rot = self.master.rot
end

bullet_spawn_ani = Class(Ani)

function bullet_spawn_ani:init(master, visual)
    Ani.init(self, master, visual)

    self.img = "fog"
    self.blend = ""
    self.a = 0
    self.r = 255
    self.g = 255
    self.b = 255
    self.scale_x = 5
    self.scale_y = 5
    self.z = 0.5
    self.layer = Visual.Layer.ENEMY_BULLET_EF

    Task.New(self, function()
        for i = 1, 8 do
            local t = i / 8

            self.a = Math.Ease.Lerp(0, 255, t, 0)
            self.scale_x = Math.Ease.Lerp(3, 0.5, t, 4)
            self.scale_y = Math.Ease.Lerp(3, 0.5, t, 4)

            Task.Wait(1)
        end
        --self.img = "grain_a"
        self.visual:play("body")
    end)
end

function bullet_spawn_ani:frame()
    self.x = self.master.x
    self.y = self.master.y
    self.rot = self.master.rot
end

bullet_visual = Class(Visual)

function bullet_visual:init(master)
    Visual.init(self, master)

    self.layer = Visual.Layer.ENEMY_BULLET

    self:addAni("spawn", bullet_spawn_ani)
    self:addAni("body", bullet_body_ani)

    self:play("spawn")
end

bullet_unit = Class(Unit)

function bullet_unit:init(x, y, angle, speed)
    self.x = x or 0
    self.y = y or 0

    Unit.SetV(self, speed or 3, angle or 0)

    self.visual = Visual.New(bullet_visual, self)
end

function bullet_unit:frame()
    if View.IsOutWorld(self.x, self.y, 64) then
        Unit.Del(self)
    end
end

function bullet_unit:del()
    if self.visual then
        Visual.Del(self.visual)
        self.visual = nil
    end
end

local function bullet(x, y, angle, speed)
    return Unit.New(bullet_unit, x, y, angle, speed)
end

-- ============================================================
-- Boss visual
-- ============================================================

boss_ani = Class(Ani)

function boss_ani:init(master, visual)
    Ani.init(self, master, visual)

    self.img = "img.ball"
    self.blend = ""
    self.a = 255
    self.r = 255
    self.g = 255
    self.b = 255
    self.scale_x = 0.35
    self.scale_y = 0.35
    self.z = 0.5
end

function boss_ani:frame()
    self.x = self.master.x
    self.y = self.master.y
    self.rot = self.master.rot
end

boss_visual = Class(Visual)

function boss_visual:init(master)
    Visual.init(self, master)

    self.layer = Visual.Layer.ENEMY

    self:addAni("body", boss_ani)
    self:play("body")
end

-- ============================================================
-- Boss unit / pattern
-- ============================================================

boss_unit = Class(Unit)

function boss_unit:init()
    self.x = 0
    self.y = 96
    self.rot = 0

    --self.visual = Visual.New(boss_visual, self)

    Task.New(self, function()
        Task.Wait(30)

        local ang = 0
        local x = 0
        local v = 3

        while true do
            local fx = ((-2 / 9) / 2) * x + 14 / 3
            ang = ang + fx

            local count = 8

            for i = 1, count do
                local theta = (i - 1) * (360 / count)
                local a = ang + theta

                local offset_x = 6 * cosd(a)
                local offset_y = 6 * sind(a)

                bullet(
                    self.x + offset_x,
                    self.y + offset_y,
                    a,
                    v
                )
            end

            x = x + 1
            Task.Wait(2)
        end
    end)
end

function boss_unit:frame()
    self.rot = self.rot + 1
end

function boss_unit:del()
    if self.visual then
        Visual.Del(self.visual)
        self.visual = nil
    end
end

Unit.New(boss_unit)

Debug.Print("[mod/Test] script.lua finished")