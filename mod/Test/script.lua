Resource.Image.LoadTexture("tex.ball", "ball_huge_blue.png")
Resource.Image.LoadFullSprite("img.ball", "tex.ball", 0.5, 0.5)

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function lerp_color(c1, c2, t)
    return
        lerp(c1[1], c2[1], t),
        lerp(c1[2], c2[2], t),
        lerp(c1[3], c2[3], t)
end

local function play_color_cycle(chip)
    local colors = {
        {255, 255, 255},
        {0,   255, 255},
        {0,   0,   255},
        {255, 0,   255},
        {255, 0,   0},
        {255, 255, 0},
        {255, 255, 255},
    }

    while true do
        for i = 1, #colors - 1 do
            local from = colors[i]
            local to = colors[i + 1]

            for frame = 0, 59 do
                local t = frame / 59
                chip.r, chip.g, chip.b = lerp_color(from, to, t)
                task.Wait(1)
            end
        end
    end
end

test_unit = Class(Unit)

function test_unit:init()
    self.x = 0
    self.y = 0
    self.rot = 0

    self.body_visual = NewVisual(body_visual, self)
    self.fx_visual = NewVisual(fx_visual, self)

    task.New(self, function()
        while true do
            -- 本体：白色普通显示
            self.body_visual:play("normal")
            task.Wait(90)

            -- 本体：开始循环变色
            self.body_visual:play("color_cycle")
            task.Wait(60)

            -- 特效：大号慢扩散
            self.fx_visual:play("burst_big")
            task.Wait(60)

            -- 转一圈并移动一下
            for i = 1, 120 do
                local a = i / 120 * math.pi * 2
                self.x = 100 * math.cos(a)
                self.y = 80 * math.sin(a)
                self.rot = self.rot + 3
                task.Wait(1)
            end

            -- 特效：小号快扩散，连发几次
            for i = 1, 5 do
                self.fx_visual:play("burst_small")
                task.Wait(15)
            end

            -- 回到中心
            for i = 1, 60 do
                local t = i / 60
                self.x = lerp(self.x, 0, t)
                self.y = lerp(self.y, 0, t)
                self.rot = self.rot + 5
                task.Wait(1)
            end
        end
    end)
end

function test_unit:frame()
    self.rot = self.rot + 1
end

-- visual 1：本体显示 / 本体变色
body_visual = Class(Visual)

function body_visual:init(master)
    Visual.init(self, master)

    self.layer = 0

    self:addChip("normal", body_normal_chip)
    self:addChip("color_cycle", body_color_cycle_chip)

    self:play("normal")
end

body_normal_chip = Class(Chip)

function body_normal_chip:init(master, visual)
    Chip.init(self, master, visual)

    self.img = "img.ball"
    self.blend = ""
    self.a = 255
    self.r, self.g, self.b = 255, 255, 255
    self.scale_x = 1
    self.scale_y = 1
    self.z = 0.5
end

function body_normal_chip:frame()
    self.x = self.master.x
    self.y = self.master.y
    self.rot = self.master.rot
end

body_color_cycle_chip = Class(Chip)

function body_color_cycle_chip:init(master, visual)
    Chip.init(self, master, visual)

    self.img = "img.ball"
    self.blend = ""
    self.a = 255
    self.r, self.g, self.b = 255, 255, 255
    self.scale_x = 1
    self.scale_y = 1
    self.z = 0.5

    task.New(self, function()
        play_color_cycle(self)
    end)
end

function body_color_cycle_chip:frame()
    self.x = self.master.x
    self.y = self.master.y
    self.rot = self.master.rot
end

-- visual 2：扩散特效
fx_visual = Class(Visual)

function fx_visual:init(master)
    Visual.init(self, master)

    self.layer = -1

    self:addChip("burst_big", burst_big_chip)
    self:addChip("burst_small", burst_small_chip)

    self:play("burst_big")
end

burst_big_chip = Class(Chip)

function burst_big_chip:init(master, visual)
    Chip.init(self, master, visual)

    self.img = "img.ball"
    self.blend = "mul+add"
    self.a = 255
    self.r, self.g, self.b = 0, 255, 255
    self.scale_x = 1
    self.scale_y = 1
    self.z = 0.4

    task.New(self, function()
        for frame = 0, 59 do
            local t = frame / 59

            self.a = lerp(255, 0, t)
            self.scale_x = lerp(1, 5, t)
            self.scale_y = self.scale_x

            task.Wait(1)
        end

        self.a = 0
    end)
end

function burst_big_chip:frame()
    self.x = self.master.x
    self.y = self.master.y
    self.rot = self.master.rot + self.timer * 2
end

burst_small_chip = Class(Chip)

function burst_small_chip:init(master, visual)
    Chip.init(self, master, visual)

    self.img = "img.ball"
    self.blend = "mul+add"
    self.a = 255
    self.r, self.g, self.b = 255, 255, 0
    self.scale_x = 1
    self.scale_y = 1
    self.z = 0.45

    task.New(self, function()
        for frame = 0, 29 do
            local t = frame / 29

            self.a = lerp(255, 0, t)
            self.scale_x = lerp(1, 3, t)
            self.scale_y = self.scale_x

            task.Wait(1)
        end

        self.a = 0
    end)
end

function burst_small_chip:frame()
    self.x = self.master.x
    self.y = self.master.y
    self.rot = self.master.rot - self.timer * 6
end

New(test_unit)