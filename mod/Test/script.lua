Resource.Image.LoadTexture("tex.ball", "ball_huge_blue.png")
Resource.Image.LoadFullSprite("img.ball", "tex.ball", 0.5, 0.5)

--Resource.Image.LoadTexture("tex.ball", "crop.png")
--Resource.Image.LoadFullSprite("img.ball", "tex.ball", 0.5, 0.5)
test_unit = Class(Unit)

function test_unit:init()
    self.x = 0
    self.y = 0
    self.rot = 0
    self.r = 0
    self.ang = 0
    --SetV(self,-3,0)

    self.visual = NewVisual(test_visual, self)
end

function test_unit:frame()
    --self.r = 100 * math.sin(self.timer/10000)
    --self.x,self.y = self.r * math.cos(self.ang),self.r * math.sin(self.ang)
    self.ang = self.ang + 1
    
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
end

function test_chip:frame()
    self.rot = self.master.rot
    self.blend = "mul+add"

    local phase = math.floor(self.timer / 60) % 3

    if phase == 0 then
        self.r, self.g, self.b = 0, 255, 255
    elseif phase == 1 then
        self.r, self.g, self.b = 255, 0, 255
    else
        self.r, self.g, self.b = 255, 255, 0
    end
end

New(test_unit)