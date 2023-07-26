local esp = {data = {}, settings = {box = {false, Color3.new(1, 1, 1), 0}, tracer = {false, Color3.new(1, 1, 1), 0}, name = {false, Color3.new(1, 1, 1), 0}, pointer = {false, Color3.new(1, 1, 1), 0}}, new = {add = {}, remove = {}, update = {}, disable = {}}};

local players = game:GetService("Players");
local localPlayer = players.LocalPlayer;

do

    -- // esp:new adds a function

    function esp:newData(type, data)
        
        assert(self.new[type], string.format("Type %s doesn't exist.", type));

        table.insert(self.new[type], data);

    end;

    function esp:newOption(type, visible, color, transparency)

        self.settings[type] = {visible == nil and false or visible, color or Color3.new(1, 1, 1), transparency or 0};

    end;

    function esp:update(type, visible, color, transparency)
        
        assert(self.settings[type], string.format("Type %s doesn't exist.", type));

        local data = self.settings[type];

        data[1] = visible;
        data[2] = color;
        data[3] = transparency;

    end;

    function esp:camera()
        
        return workspace.CurrentCamera;

    end;

    function esp:rotateVector(vector, radians)

        local unit = vector.Unit;

        local sin, cos = math.sin(radians), math.cos(radians);

        return Vector2.new((cos * unit.X) - (sin * unit.Y), (sin * unit.X) + (cos * unit.Y)).Unit * vector.Magnitude;

    end;

    -- // function below is pasted from BitchingBoching v2

    function esp:angleToEdge(angle, inset)

        local viewportSize = self:camera().ViewportSize;

        local result;

        local unit = Vector2.new(math.cos(angle), math.sin(angle));
        local slope = unit.Y / unit.X

        local h_edge = viewportSize.X - inset;
        local v_edge = viewportSize.X - inset;

        if unit.X < 0 then

            h_edge = inset;

        end;
        if unit.Y < 0 then

            v_edge = inset;

        end;

        local y = (slope * h_edge) + (viewportSize.Y / 2) - slope * (viewportSize.X / 2)
        if y > 0 and y < viewportSize.Y - inset then

            result = Vector2.new(h_edge, y);

        else

            result = Vector2.new((v_edge - viewportSize.Y / 2 + slope * (viewportSize.X / 2)) / slope, v_edge);

        end;

        return result;

    end;
    
    function esp:vector3ToVector2(vector)

        return Vector2.new(vector.X, vector.Y);

    end;

    function esp:new_drawing(class, properties)

        local draw = Drawing.new(class);

        for key, value in next, properties do
            
            draw[key] = value;

        end;

        return draw;

    end;

    function esp:add_player(player)
        
        assert(self.data[player] == nil, "ESP data already exists for that player.");

        self.data[player] = {
            box = self:new_drawing("Square", {Filled = false, Thickness = 1});
            tracer = self:new_drawing("Line", {Thickness = 1});
            name = self:new_drawing("Text", {Font = 2, Size = 13, Center = true, Outline = false, Text = player.Name});
            pointer = self:new_drawing("Triangle", {Filled = true, Thickness = 1});
        };

        for _, data in next, self.new.add do
            
            data(player, self.data[player]); -- // give options 4 player and data

        end;

    end;

    function esp:remove_player(player)
        
        assert(self.data[player] ~= nil, "No ESP data to remove.");

        for _, draw in next, self.data[player] do
            
            draw:Remove();

        end;

        self.data[player] = nil;

        for _, data in next, self.new.remove do
            
            data();

        end;

    end;

    function esp:get_flag(player)

        if player.Team ~= localPlayer.Team then
            
            return "enemies";

        elseif player.Team == localPlayer.Team then

            if player == localPlayer then
                
                return "self";

            else

                return "friendlies";

            end;

        end;

    end;

    function esp:update_player(player, position)

        local data = self.data[player];

        assert(data ~= nil, "No player ESP data exists.");

        local camera = self:camera();

        local position, visible = camera:WorldToViewportPoint(position);
        local position2d = self:vector3ToVector2(position);

        local flag = self:get_flag(player);

        if visible then
            
            data.pointer.Visible = false;

            local calculatedSize;

            do
                
                local position, size = player.Character:GetBoundingBox();

                local addX = (camera.CFrame - camera.CFrame.p) * Vector3.new(math.clamp(math.abs(size.X / 2) + 0.5, 0, 2), 0, 0);
                local addY = (camera.CFrame - camera.CFrame.p) * Vector3.new(0, math.clamp(math.abs(size.Y / 2) + 0.5, 0, 3), 0);

                local left = camera:WorldToViewportPoint(position.p + addX);
                local right = camera:WorldToViewportPoint(position.p - addX);

                local top = camera:WorldToViewportPoint(position.p + addY);
                local bottom = camera:WorldToViewportPoint(position.p - addY);

                calculatedSize = Vector2.new(math.max(math.abs(left.X - right.X), 5), math.max(math.abs(top.Y - bottom.Y), 7));

            end;
            
            if self.settings.tracer[1] then
                
                data.tracer.Color = self.settings.tracer[2];
                data.tracer.Transparency = self.settings.tracer[3];
                data.tracer.From = camera.ViewportSize / 2;
                data.tracer.To = position2d;

                data.tracer.Visible = true;

            else

                data.tracer.Visible = false;

            end;

            if self.settings.box[1] then
                
                data.box.Color = self.settings.box[2];
                data.box.Transparency = 1 - self.settings.box[3];
                data.box.Size = calculatedSize;
                data.box.Position = position2d - calculatedSize * 0.5;
                data.box.Visible = true;

            else

                data.box.Visible = false;

            end;

            if self.settings.name[1] then
                
                data.name.Color = self.settings.name[2];
                data.name.Transparency = 1 - self.settings.name[3];
                data.name.Position = position2d - Vector2.new(0, calculatedSize.Y * 0.5 + 16);
                data.name.Visible = true;

            else

                data.name.Visible = false;

            end;

            for _, dataFunction in next, self.new.update do
                
                dataFunction(player, data, true, calculatedSize, position);

            end;

        else

            local angle = math.acos(position.X);

            local unit = position2d.Unit;

            if self.settings.pointer[1] then
                
                local sizeUnit = camera.ViewportSize / 32;

                data.pointer.Color = self.settings.pointer[2];
                data.pointer.Transparency = 1 - self.settings.pointer[3];
                data.pointer.PointA = self:angleToEdge(angle, 10);
                data.pointer.PointB = data.pointer.PointA - self:rotateVector(unit, math.pi / 4) * sizeUnit;
                data.pointer.PointC = data.pointer.PointA - self:rotateVector(unit, -math.pi / 4) * sizeUnit;

                data.pointer.Visible = true;

            else

                data.pointer.Visible = false;

            end;

            if self.settings.tracer[1] then
                
                data.tracer.Color = self.settings.tracer[2];
                data.tracer.Transparency = 1 - self.settings.tracer[3];
                data.tracer.From = camera.ViewportSize / 2;
                data.tracer.To = self:angleToEdge(math.atan2(position.Y, position.X), 0);

                data.tracer.Visible = true;

            else

                data.tracer.Visible = false;

            end;

            data.box.Visible = false;
            data.name.Visible = false;

            for _, dataFunction in next, self.new.update do
                
                dataFunction(player, data, false, Vector2.zero, position);

            end;

        end;

    end;

    function esp:disable_esp(player)
        
        for _, draw in next, self.data[player] do
            
            draw.Visible = false;

        end;

        for _, data in next, self.new.disable do
                
            data(player, self.data[player]);

        end;

    end;

end;

return esp;
