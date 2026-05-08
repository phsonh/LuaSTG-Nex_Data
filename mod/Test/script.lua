test_unit = Class(Unit)

function test_unit:init()
    self.x = 100
    self.y = 200
    self.vx = 1
    self.vy = 0.5
    self.ax = 0
    self.ay = 0
    self.rot = 0

    Log(2, string.format(
        "[test_unit] init id=%s x=%.2f y=%.2f",
        tostring(self.id),
        self.x,
        self.y
    ))
end

function test_unit:frame()
    self.rot = self.rot + 1

    if self.timer % 60 == 0 then
        Log(2, string.format(
            "[test_unit] timer=%s x=%.2f y=%.2f rot=%.2f count=%s",
            tostring(self.timer),
            self.x,
            self.y,
            self.rot,
            tostring(lstg.Unit.count())
        ))
    end
end

New(test_unit)