local cursor = {angle = 0, visible = false, outline = false, dot = false, from = Vector2.zero, gap = 0, radius = 10, color = Color3.new(1, 1, 1), outlineColor = Color3.new(0, 0, 0), mode = "default", instances = {}, outlines = {}, dots = {}};

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

    function cursor:floorVector2(vector)
        
        return Vector2.new(math.floor(vector.X), math.floor(vector.Y));

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

            for count, draw in next, self.outlines do
                
                local angle = math.rad(self.angle + (count * 90));

                draw.Color = self.outlineColor;
                draw.From = self.from + Vector2.new(math.cos(angle), math.sin(angle)) * (self.gap - 1);
                draw.To = self.from + Vector2.new(math.cos(angle), math.sin(angle)) * (self.radius + self.gap + 1);

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

            for count, draw in next, self.outlines do

                local angle = math.rad(self.angle + (count < 5 and count * 90 or count * 90 - 45));
                local increase = count > 4 and math.sqrt(2) or 1;

                draw.Color = self.outlineColor;

                local from, to = self.from + Vector2.new(math.cos(angle), math.sin(angle)) * (self.gap - 1) * increase, self.from + Vector2.new(math.cos(angle), math.sin(angle)) * (self.radius + self.gap + 1) * increase;
                
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

            for count, draw in next, self.outlines do

                local angle = math.rad(self.angle + count * 90 - 45);
                local increase = count > 2 and math.sqrt(2) or 1;

                draw.Color = self.outlineColor;
                draw.From = self.from + Vector2.new(math.cos(angle), math.sin(angle)) * (self.gap - 1) * increase;
                draw.To = self.from + Vector2.new(math.cos(angle), math.sin(angle)) * (self.gap + self.radius + 1) * increase;

            end;

        end;

        for count = 1, 2 do
            
            self.dots[count].Position = self.from - (self.dots[1].Size / 2) - (Vector2.new(1, 1) * (count - 1));
            self.dots[count].Color = count == 1 and self.color or self.outlineColor;
            self.dots[count].Visible = count == 1 and self.visible or count == 2 and self.visible and self.outline;

        end;

    end;

    function cursor:update_dot(enabled)
        
        self.dot = enabled;

        for count = 1, 2 do
            
            self.dots[count].Visible = count == 1 and self.visible or count == 2 and self.visible and self.outline;

        end;

    end;

    function cursor:update_outline(enabled)
        
        self.outline = enabled;

        for _, draw in next, self.outlines do
            
            draw.Visible = self.visible and self.outline or false;

        end;

    end;

    function cursor:update_outline_color(new)
        
        self.outlineColor = new;

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
        
        self.from = self:floorVector2(from);

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

        for _, draw in next, self.outlines do
            
            draw.Visible = self.visible and self.outline or false;

        end;

        for count = 1, 2 do
            
            self.dots[count].Visible = count == 1 and self.visible or count == 2 and self.visible and self.outline;

        end;

    end;

    function cursor:update_color(color)
        
        self.color = color;

    end;

    function cursor:init()
        
        for _, draw in next, self.instances do
            
            draw:Remove();

        end;

        for _, draw in next, self.outlines do
            
            draw:Remove();

        end;

        table.clear(self.instances);
        table.clear(self.outlines);

        if self.mode == "default" then
            
            for count = 1, 4 do
                
                self.instances[count] = self:newDrawing("Line", {Thickness = 1});

            end;

        elseif self.mode == "nazi" then
            
            for count = 1, 8 do
                
                self.instances[count] = self:newDrawing("Line", {Thickness = 1});

            end;

        elseif self.mode == "trapezium" then

            for count = 1, 4 do
                
                self.instances[count] = self:newDrawing("Line", {Thickness = 1});

            end;

        end;

        for count, draw in next, self.instances do
            
            self.outlines[count] = self:newDrawing("Line", {Thickness = draw.Thickness + 2, ZIndex = draw.ZIndex - 1});

        end;

        for count = 1, 2 do
            
            self.dots[count] = self:newDrawing("Square", {Filled = true, ZIndex = 2 - count, Size = Vector2.new(2, 2) + Vector2.new(2, 2) * (count - 1)});

        end;
        
    end;

    cursor:init();

end;

return cursor;
