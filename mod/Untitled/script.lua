function boss1(self)
    task.New(self,function ()
        task.Wait(90)
        local ang,x,fx = 0,0,0
        local dmk0 = danmaku:new()
        dmk0:set_type("grain_a",3)
        dmk0:set_num(1,1)
        dmk0:set_form("fan",0)
        dmk0:set_sound("kira00")
        dmk0:set_speed(3,1)
        while true do
            fx = ((-2/9)/2)*x + 14/3
            ang = ang + fx
            local count = 8
            for i=1, count do
                local theta = (i-1) * (360 / count)
                
                local a = ang + theta
                local offsetX, offsetY = 5 * cos(a), 5 * sin(a)
                
                --local b = New(bullet,"grain_a", 3, self.x + offsetX, self.y + offsetY, 3, a, 0, false)
                --local b_fog = bullet_mgr.bullet_effect.fog["grain_a"]
                --bullet_fog(b,3,25,b_fog.alpha.start_alpha,b_fog.alpha.tag_alpha,b_fog.scale.start_scale,b_fog.scale.tag_scale,b_fog.use_bullet_img)
                --bullet_fog(b,3,8,0,255,3,0.5,b_fog.use_bullet_img)
                dmk0:set_angle(a,0)
                dmk0:set_offset(offsetX,offsetY)
                dmk0:shoot(self)
            end
            x = x + 1
            task.Wait(2)
        end
        
    end)
end