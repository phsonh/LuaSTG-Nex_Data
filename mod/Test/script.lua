test_unit = Class(Unit)

function test_unit:init()
    self.x = 1
    self.y = 0
    SetV(self, 3.1415926, 0)
    self.rot = 0
    Log(2, string.format(
        "[test_unit] init x=%.2f y=%.2f rot=%.2f vx=%.2f vy=%.2f",
        self.x,
        self.y,
        self.rot,
        self.vx,
        self.vy
    ))
end

function test_unit:frame()
    self.rot = self.rot + 1

    if self.timer % 1 == 0 then
        Log(2, string.format(
            "[test_unit] timer=%s x=%.2f y=%.2f rot=%.2f vx=%.2f vy=%.2f",
            tostring(self.timer),
            self.x,
            self.y,
            self.rot,
            self.vx,
            self.vy
        ))
    end
end

New(test_unit)