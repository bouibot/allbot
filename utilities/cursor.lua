local cursor = {angle = 0, visible = false, from = Vector2.zero, gap = 0, radius = 10, color = Color3.new(1, 1, 1), mode = "default", instances = {}};

do
    
    function cursor:getModes()
        
        return {"default", "trapezium", "nazi"}

    end;

    function cursor:newDrawing(class, properties)
        
        local draw = Drawing.new(class);

        for key, value in next, properties or {} do
            
            draw[key] = value;

        end;

        return draw;

    end;

    function cursor:update()
        
        if not self.visible then
            
            return;

        end;

        if self.mode == "default" then
            
            for count, draw in next, self.instances do
                
                local angle = math.rad(self.angle + (count * 90));

                draw.Color = self.color;
                draw.From = self.from + Vector2.new(math.cos(angle), math.sin(angle)) * self.gap;
                draw.To = self.from + Vector2.new(math.cos(angle), math.sin(angle)) * (self.radius + self.gap);

            end;

        elseif self.mode == "nazi" then
            
            local saved = {};

            for count, draw in next, self.instances do
                
                local angle = math.rad(self.angle + (count < 5 and count * 90 or count * 90 - 45));
                local increase = count > 4 and math.sqrt(2) or 1;

                draw.Color = self.color;

                local from, to = self.from + Vector2.new(math.cos(angle), math.sin(angle)) * self.gap * increase, self.from + Vector2.new(math.cos(angle), math.sin(angle)) * (self.radius + self.gap) * increase;
                
                if count < 5 then
                    
                    saved[count] = to;

                    draw.From = from;
                    draw.To = to;

                else

                    draw.From = saved[count - 4];
                    draw.To = to;

                end;

            end;

        elseif self.mode == "trapezium" then

            for count, draw in next, self.instances do
                
                local angle = math.rad(self.angle + count * 90 - 45);
                local increase = count > 2 and math.sqrt(2) or 1;

                draw.Color = self.color;
                draw.From = self.from + Vector2.new(math.cos(angle), math.sin(angle)) * self.gap * increase;
                draw.To = self.from + Vector2.new(math.cos(angle), math.sin(angle)) * (self.gap + self.radius) * increase;

            end;

        end;

    end;

    function cursor:update_angle(amount)
        
        self.angle = amount;

    end;

    function cursor:update_radius(new)
        
        self.radius = new;

    end;

    function cursor:update_gap(new)
        
        self.gap = new;

    end;

    function cursor:update_from(from)
        
        self.from = from;

    end;

    function cursor:update_mode(mode)
        
        self.mode = mode;

        self:init();

    end;

    function cursor:update_visibility(visible)
        
        self.visible = visible;

        for _, draw in next, self.instances do
            
            draw.Visible = self.visible;

        end;

    end;

    function cursor:update_color(color)
        
        self.color = color;

    end;

    function cursor:init()
        
        for _, draw in next, self.instances do
            
            draw:Remove();

        end;

        table.clear(self.instances);

        if self.mode == "default" then
            
            for count = 1, 4 do
                
                self.instances[count] = self:newDrawing("Line", {Thickness = 2});

            end;

        elseif self.mode == "nazi" then
            
            for count = 1, 8 do
                
                self.instances[count] = self:newDrawing("Line", {Thickness = 2});

            end;

        elseif self.mode == "trapezium" then

            for count = 1, 4 do
                
                self.instances[count] = self:newDrawing("Line", {Thickness = 2});

            end;

        end;

    end;

    cursor:init();

end;

return cursor;
