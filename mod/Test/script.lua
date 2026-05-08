Resource.Image.LoadTexture("tex.ball", "ball_huge_blue.png")
Resource.Image.LoadFullSprite("img.ball", "tex.ball", 1, 1)

test_unit = Class(Unit)

function test_unit:init()
    self.x = 0
    self.y = 0
    self.rot = 0
    SetV(self, 2, -90)

    self.visual = NewVisual(test_visual, self)

    Console.Print("[test_unit] created")
end

function test_unit:frame()
    self.rot = self.rot - 1
end

test_visual = Class(Visual)

function test_visual:init(master)
    Visual.init(self, master)

    self:addChip("body", test_chip)
    self:play("body")
end

test_chip = Class(Chip)

function test_chip:init(master, visual)
    Chip.init(self, master, visual)

    self.img = "img.ball"
    self.space = "local"

    self.x = 0
    self.y = 0
    self.rot = 0

    self.scale_x = 2
    self.scale_y = 2

    self.blend = ""
    self.a = 255
    self.r = 255
    self.g = 255
    self.b = 255
end

function test_chip:frame()
    --self.rot = self.master.rot
    self.rot = self.rot + 1
end

function test_chip:render()
    if self.timer % 60 == 0 then
        Console.Print(string.format(
            "[test_chip] render img=%s x=%.2f y=%.2f rot=%.2f",
            tostring(self.img),
            self.master.x,
            self.master.y,
            self.rot
        ))
    end

    Chip.render(self)
end

New(test_unit)