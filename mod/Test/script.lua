Resource.Image.LoadTexture("tex.ball", "ball_huge_blue.png")
Resource.Image.LoadFullSprite("img.ball", "tex.ball", 1, 1)

test_unit = Class(Unit)

function test_unit:init()
    self.x = 0
    self.y = 0
    self.rot = 0

    self.visual = NewVisual(test_visual, self)

    Console.Print("[test_unit] created")
    Console.Print("lstg.LoadTexture = " .. tostring(lstg.LoadTexture))
    Console.Print("lstg.LoadImage = " .. tostring(lstg.LoadImage))
    Console.Print("lstg.LoadAnimation = " .. tostring(lstg.LoadAnimation))
    Console.Print("lstg.SetImageState = " .. tostring(lstg.SetImageState))

    Console.Print("Resource.Image.LoadTexture = " .. tostring(Resource.Image.LoadTexture))
    Console.Print("Resource.Image.LoadSprite = " .. tostring(Resource.Image.LoadSprite))
    Console.Print("Resource.Audio.LoadSound = " .. tostring(Resource.Audio.LoadSound))
    Console.Print("Resource.File.LoadText = " .. tostring(Resource.File.LoadText))
end

function test_unit:frame()
    self.rot = self.rot + 1
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
end

New(test_unit)