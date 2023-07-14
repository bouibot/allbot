local runService = game:GetService("RunService");
local userInputService = game:GetService("UserInputService");
local tweenService = game:GetService("TweenService");

local allbot = game:GetObjects("rbxassetid://14051345033")[1];

local tab = allbot.main.tabs.tab;

local left, right, extra = allbot.main.content.left, allbot.main.content.right, allbot.main.content.extra;

local section = allbot.main.content.left.section;
local button = section.button;
local toggle = section.toggle;
local textbox = section.textbox;
local slider = section.slider;
local dropdown = section.dropdown;
local colorpicker = section.colorpicker;
local keybind = section.keybind;

local dropdown_drop = allbot.main.content.extra.dropdown;
dropdown_drop.ZIndex = 4;

for i, child in next, dropdown_drop:GetDescendants() do

	if pcall(function() return child.ZIndex end) then

		child.ZIndex = 5;

	end;

end;

local colorpicker_drop = allbot.main.content.extra.colorpicker;
colorpicker_drop.ZIndex = 4;

for i, child in next, colorpicker_drop:GetDescendants() do

	if pcall(function() return child.ZIndex end) then

		child.ZIndex = 5 + i;

	end;

end;

local request = request or http_request or (syn and syn.request);
local getcustomasset = getsynasset or getcustomasset;

if not isfolder("allbot") then

    makefolder("allbot");

end;

if not isfolder("allbot/assets") then

    makefolder("allbot/assets");

end;

function get_custom_asset(path)

    local link = "https://raw.githubusercontent.com/bouibot/allbot/main/";

    if not isfile(path) then

        local response = request({Method = "GET", Url = link .. string.gsub(path, "allbot/", "")}).Body;

        writefile(path, response);

    end;

    return getcustomasset(path);

end;

local library = {
	assets = {
		["rbxassetid://13901004307"] = get_custom_asset("allbot/assets/color.png");
		["rbxassetid://505777302"] = get_custom_asset("allbot/assets/checkers_big.webp");
		["rbxassetid://13900445654"] = get_custom_asset("allbot/assets/checkers.png");
	};
	theme = {
		accent = Color3.fromRGB(0, 255, 255);
	};
	scale = 1;
	toggle_key = Enum.KeyCode.Home;
	pointers = {};
};

local utility = {};

do
	
	function utility:connect(signal, callback)
		
		local connection = signal:Connect(callback);
		
		return connection;
		
	end;
	
	function utility:mouseLocation()
		
		return userInputService:GetMouseLocation();
		
	end;
	
	function utility:overInstance(instance: TextLabel)
		
		local topbarSize = 36;
		
		local position = self:mouseLocation() - Vector2.new(0, topbarSize);
		
		local toCheck = {instance.AbsolutePosition, instance.AbsolutePosition + instance.AbsoluteSize};
		
		return position.X >= toCheck[1].X and position.Y >= toCheck[1].Y and position.X <= toCheck[2].X and position.Y <= toCheck[2].Y;
		
	end;
	
	function utility:vector2ToUDim2(vector: Vector2)
		
		return UDim2.new(0, vector.X, 0, vector.Y);
		
	end;
	
end;

local sectionClass = {};
sectionClass.__index = sectionClass;

do

	function sectionClass:update()

		local totalSize = 32;

		for _, child in next, self.frame:GetChildren() do

			if child:IsA("Frame") and not table.find({"bg", "accent"}, child.Name) then

				totalSize += child.Size.Y.Offset + 5;

			end;

		end;

		self.frame.Size = UDim2.new(1, -8, 0, (self.size ~= nil and self.size) or totalSize);

		if self.size ~= nil and self.size < totalSize then
			
			self.frame.CanvasSize = UDim2.new(0, 0, 0, totalSize);

		end;

	end;

	function sectionClass:button(data)

		local button = button:Clone();
		button.Parent = self.frame;
		button.button.title.Text = data.title or "button";
		
		local offset = 32;
		
		for _, child in next, self.frame:GetChildren() do
			
			if child:IsA("Frame") and not table.find({"bg", "accent"}, child.Name) and child ~= button then
				
				offset += child.Size.Y.Offset + 5;
				
			end;
			
		end;
		
		button.Position = UDim2.new(0, 0, 0, offset);

		utility:connect(button.button.MouseButton1Click, data.callback or function() end);

		self:update();

	end;
	
	function sectionClass:toggle(data)
		
		local toggle = toggle:Clone();
		toggle.Parent = self.frame;
		toggle.button.title.Text = data.title or "toggle";
		
		local offset = 32;

		for _, child in next, self.frame:GetChildren() do

			if child:IsA("Frame") and not table.find({"bg", "accent"}, child.Name) and child ~= toggle then

				offset += child.Size.Y.Offset + 5;

			end;

		end;

		toggle.Position = UDim2.new(0, 0, 0, offset);
		
		local toggle = {state = false, frame = toggle, callback = data.callback or function() end};
		
		function toggle:get()
			
			return self.state;
			
		end;
		
		function toggle:set(value)
			
			self.state = value;
			
			tweenService:Create(toggle.frame.toggle, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {BackgroundColor3 = self.state and library.theme.accent or Color3.fromRGB(45, 45, 45)}):Play()
			
			self.callback(self.state);
			
		end;
		
		utility:connect(toggle.frame.button.MouseButton1Click, function()
			toggle:set(not toggle.state);
		end);
		
		if data.pointer then
			
			library.pointers[data.pointer] = toggle;
			
		end;
		
		toggle:set(data.default or false);
		
		self:update();
		
	end;
	
	function sectionClass:dropdown(data)
		
		local dropdown = dropdown:Clone();
		dropdown.Parent = self.frame;
		dropdown.title.Text = data.title or "dropdown";
		
		local offset = 32;

		for _, child in next, self.frame:GetChildren() do

			if child:IsA("Frame") and not table.find({"bg", "accent"}, child.Name) and child ~= dropdown then

				offset += child.Size.Y.Offset + 5;

			end;

		end;

		dropdown.Position = UDim2.new(0, 0, 0, offset);
		
		local dropdown = {frame = dropdown, title = dropdown.title.Text, options = data.options, min = data.min or 0, multi = data.multi or false, value = data.default, drop = nil, connection = nil, callback = data.callback or function() end, section = self};
		
		function dropdown:generate_name()
			
			local result = "";
			
			for _, option in next, self.value do
				
				result ..= option .. ", ";
				
			end;
			
			return string.sub(result, 1, -3);
			
		end;
		
		function dropdown:update()
			
			self.frame.dropthingy.title.Text = self:generate_name();
			
			if self.drop then
				
				for _, button in next, self.drop:GetChildren() do
					
					if button.Name ~= "bg" then
						
						button.title.TextColor3 = table.find(self.value, button.title.Text) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(170, 170, 170);
						
					end;
					
				end;
				
			end;
			
		end;
		
		function dropdown:open()
			
			local drop = dropdown_drop:Clone();
			drop.Size = UDim2.new(0.5, -14, 0, #self.options * 25);
			drop.Position = UDim2.new(self.section.side / 2, 7, 0, self.frame.Position.Y.Offset + 60);
			drop.Parent = self.section.tab.content.extra;
			
			local button_sample = drop.button:Clone();
			drop.button:Destroy();
			
			for i, option in next, self.options do
				
				local button = button_sample:Clone();
				button.title.Text = option;
				button.title.TextColor3 = table.find(self.value, option) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(170, 170, 170);
				button.Position = UDim2.new(0, 0, 0, 25 * (i - 1));
				button.ZIndex = 15;
				button.Parent = drop;
				
				utility:connect(button.MouseButton1Click, function()
					
					if self.multi then
						
						if table.find(self.value, option) then
							
							if #self.value > self.min then
								
								table.remove(self.value, table.find(self.value, option));
								
							end;
							
						else
							
							table.insert(self.value, option);
							
						end;
						
					else
						
						self.value = {option};
						
					end;
					
					self:set(self.value);
					
				end);
				
			end;
			
			self.connection = utility:connect(runService.RenderStepped, function()
				
				drop.Position = UDim2.new(self.section.side / 2, 7, 0, self.frame.Position.Y.Offset + 60);
				
			end);
			
			self.drop = drop;
			
		end;
		
		function dropdown:close()
			
			self.connection:Disconnect();
			
			self.drop:Destroy();
			self.drop = nil;
			
		end;
		
		function dropdown:get()
			
			return self.value;
			
		end;
		
		function dropdown:set(value)
			
			self.value = value;
			
			self.callback(value);
			
			self:update();
			
		end;
		
		utility:connect(dropdown.frame.button.MouseButton1Click, function()
			
			if dropdown.drop then
				
				dropdown:close();
				
			else
				
				dropdown:open();
				
			end;
			
		end);
		
		if data.pointer then
			
			library.pointers[data.pointer] = dropdown;
			
		end;
		
		dropdown:set(dropdown.value or {dropdown.options[1]});
		
		self:update();
		
	end;
	
	function sectionClass:textbox(data)
		
		local textbox = textbox:Clone();
		textbox.Parent = self.frame;
		textbox.TextBox.PlaceholderText = data.title or "textbox";
		
		local offset = 32;

		for _, child in next, self.frame:GetChildren() do

			if child:IsA("Frame") and not table.find({"bg", "accent"}, child.Name) and child ~= textbox then

				offset += child.Size.Y.Offset + 5;

			end;

		end;

		textbox.Position = UDim2.new(0, 0, 0, offset);
		
		local textbox = {frame = textbox, title = textbox.TextBox.PlaceholderText, value = data.default};
		
		function textbox:get()
			
			return self.value;
			
		end;
		
		function textbox:set(value)
			
			self.value = value;
			
			local title = self.frame.TextBox.title;
			
			if self.value ~= "" then
				
				title.Text = self.value;
				
			else
				
				title.Text = self.title;
				
			end;
			
		end;
		
		utility:connect(textbox.frame.TextBox.Focused, function()
			
			textbox.frame.TextBox.title.TextColor3 = Color3.new(1, 1, 1);
			
		end);
		
		utility:connect(textbox.frame.TextBox.FocusLost, function()

			textbox.frame.TextBox.title.TextColor3 = Color3.fromRGB(170, 170, 170);

		end);
		
		utility:connect(textbox.frame.TextBox:GetPropertyChangedSignal("Text"), function()
			
			textbox:set(textbox.frame.TextBox.Text);

		end);
		
		if data.pointer then
			
			library.pointers[data.pointer] = textbox;
			
		end;
		
		textbox:set(textbox.value or "");
		
		self:update();
		
	end;
	
	function sectionClass:slider(data)
		
		assert(data.min, "no slider min value");
		assert(data.max, "no slider max value");
		
		local slider = slider:Clone();
		slider.Parent = self.frame;
		slider.title.Text = data.title or "slider";
		
		local offset = 32;

		for _, child in next, self.frame:GetChildren() do

			if child:IsA("Frame") and not table.find({"bg", "accent"}, child.Name) and child ~= slider then

				offset += child.Size.Y.Offset + 5;

			end;

		end;

		slider.Position = UDim2.new(0, 0, 0, offset);
		
		local slider = {frame = slider, title = slider.title.Text, min = data.min, dec = data.decimals or data.dec or 1, max = data.max, value = data.default};
		
		function slider:get()
			
			return self.value;
			
		end;
		
		function slider:set(value)
			
			self.value = value;
			
			local percent = 1 - (self.max - self.value) / (self.max - self.min);
			
			tweenService:Create(self.frame.bar.accent, TweenInfo.new(.1, Enum.EasingStyle.Linear), {Size = UDim2.new(percent, 0, 1, 0)}):Play();
			
			--self.frame.bar.accent.Size = UDim2.new(percent, 0, 1, 0);
			self.frame.bar.title.Text = string.format("%s", self.value);
			
		end;
		
		local slideConnection;
		
		utility:connect(slider.frame.button.MouseButton1Down, function()
			
			if not slideConnection then
				
				slideConnection = utility:connect(runService.RenderStepped, function()
					
					local percent = math.clamp(math.max(utility:mouseLocation().X - slider.frame.bar.AbsolutePosition.X, 0) / slider.frame.bar.AbsoluteSize.X, 0, 1);
					
					slider:set(math.floor((slider.min + (slider.max - slider.min) * percent) * slider.dec) / slider.dec);
					
				end);
				
			end;
			
		end);
		
		utility:connect(userInputService.InputEnded, function(input, gpe)
			
			if input.UserInputType == Enum.UserInputType.MouseButton1 and slideConnection then
				
				slideConnection:Disconnect();
				slideConnection = nil;
				
			end;
			
		end)
		
		if data.pointer then
			
			library.pointers[data.pointer] = slider;
			
		end;
		
		slider:set(slider.value or .5 * slider.min + .5 * slider.max)
		
		self:update();
		
	end;
	
	function sectionClass:keybind(data)
		
		local keybind = keybind:Clone();
		keybind.Parent = self.frame;
		keybind.title.Text = data.title or "keybind";
		

		local offset = 32;

		for _, child in next, self.frame:GetChildren() do

			if child:IsA("Frame") and not table.find({"bg", "accent"}, child.Name) and child ~= keybind then

				offset += child.Size.Y.Offset + 5;

			end;

		end;

		keybind.Position = UDim2.new(0, 0, 0, offset);
		
		local keybind = {frame = keybind, title = keybind.title.Text, value = data.default, binding = false, active = false, callback = data.callback or function() end};
		
		function keybind:isActive()
			
			return self.active;
			
		end;
		
		function keybind:get()
			
			return self.value;
			
		end;
		
		function keybind:set(value)
			
			self.value = value;
			
			self.frame.keybind.Text = string.format("[%s]", (self.value == Enum.KeyCode.Unknown and "") or self.value.Name);
			
			self.callback(self.value, self.active);
			
		end;
		
		utility:connect(keybind.frame.button.MouseButton1Click, function()
			
			keybind.binding = true;
			
		end);
		
		utility:connect(userInputService.InputBegan, function(input, gpe)
			
			if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
				
				
				
				if keybind.binding then
					
					
					
					if input.KeyCode == Enum.KeyCode.Escape then

						keybind.binding = false;
						keybind:set(Enum.KeyCode.Unknown);
						
					else
						
						keybind.binding = false;
						keybind:set(input.KeyCode);

					end;
					
				else
					
					if input.KeyCode == keybind:get() then
						
						keybind.active = not keybind.active;
						
					end;
					
				end;
				
			end;
			
		end);
		
		if data.pointer then
			
			library.pointers[data.pointer] = keybind;
			
		end;
		
		keybind:set(keybind.value or Enum.KeyCode.Unknown);
		
		self:update();
		
	end;
	
	function sectionClass:colorpicker(data)
		
		local colorpicker = colorpicker:Clone();
		colorpicker.Parent = self.frame;
		colorpicker.title.Text = data.title or "cp";
		
		local offset = 32;

		for _, child in next, self.frame:GetChildren() do

			if child:IsA("Frame") and not table.find({"bg", "accent"}, child.Name) and child ~= colorpicker then

				offset += child.Size.Y.Offset + 5;

			end;

		end;

		colorpicker.Position = UDim2.new(0, 0, 0, offset);
		
		local colorpicker = {frame = colorpicker, value = data.default, uisConnection = nil, section = self};
		
		function colorpicker:update()
			
			if self.drop then
				
				self.drop.color.BackgroundColor3 = Color3.fromHSV(self.tempColor[1], 1, 1);
				self.drop.color.picker.Position = UDim2.new(self.tempColor[2], -math.floor(self.tempColor[2]) * 3, 1 - self.tempColor[3], -math.floor(1 - self.tempColor[3]) * 2);
				
				self.drop.hue.picker.Position = UDim2.new(0, -3, self.tempColor[1], -math.floor(self.tempColor[1]));
				
				self.drop.transparency.picker.Position = UDim2.new(self.tempColor[4], -math.floor(self.tempColor[4]), 0, -3);
				
				self.drop.new.BackgroundColor3 = Color3.fromHSV(unpack(self.tempColor));
				self.drop.new.transparency.ImageTransparency = 1 - self.tempColor[4];
				
			end;
			
			self.frame.colorpicker.BackgroundColor3 = self.value[1];
			self.frame.colorpicker.transparency.ImageTransparency = 1 - self.value[2];
			
		end;
		
		function colorpicker:get()
			
			return self.value;
			
		end;
		
		function colorpicker:set(value)
			
			self.value = value;
			
			self:update();
			
		end;
		
		function colorpicker:open()
			
			local drop = colorpicker_drop:Clone();
			drop.Parent = self.section.tab.content.extra;
			
			drop.old.BackgroundColor3 = self.value[1];
			drop.old.transparency.ImageTransparency = 1 - self.value[2];
			
			drop.new.BackgroundColor3 = self.value[1];
			drop.new.transparency.ImageTransparency = 1 - self.value[2];
			
			local h, s, v = self.value[1]:ToHSV();
			
			drop.hue.picker.Position = UDim2.new(0, -3, h, 0);
			drop.transparency.picker.Position = UDim2.new(self.value[2], 0, 0, -3);
			
			drop.color.BackgroundColor3 = Color3.fromHSV(h, 1, 1);
			drop.color.picker.Position = UDim2.new(s, 0, 1 - v, 0);
			
			local colorDrag, hueDrag, transparencyDrag;
			
			self.tempColor = {h, s, v, self.value[2]};
			
			utility:connect(drop.color.button.MouseButton1Down, function()
				
				if not colorDrag then
					
					colorDrag = utility:connect(runService.RenderStepped, function()
						
						local offset = (utility:mouseLocation() - Vector2.new(0, 36) - drop.color.AbsolutePosition) / drop.color.AbsoluteSize;
						
						self.tempColor[2] = math.clamp(offset.X, 0, 1);
						self.tempColor[3] = math.clamp(1 - offset.Y, 0, 1);
						
						self:update();
						
					end);
					
				end;
				
			end);
			
			utility:connect(drop.hue.button.MouseButton1Down, function()

				if not hueDrag then

					hueDrag = utility:connect(runService.RenderStepped, function()

						local offset = (utility:mouseLocation().Y - 36 - drop.hue.AbsolutePosition.Y) / drop.hue.AbsoluteSize.Y;
						
						self.tempColor[1] = math.clamp(offset, 0, 1); 

						self:update();

					end);

				end;

			end);
			
			utility:connect(drop.transparency.button.MouseButton1Down, function()

				if not transparencyDrag then

					transparencyDrag = utility:connect(runService.RenderStepped, function()

						local offset = (utility:mouseLocation().X - drop.transparency.AbsolutePosition.X) / drop.transparency.AbsoluteSize.X;

						self.tempColor[4] = math.clamp(offset, 0, 1); 

						self:update();

					end);

				end;

			end);
			
			utility:connect(drop.apply.MouseButton1Click, function()
				
				colorpicker:set({Color3.fromHSV(unpack(self.tempColor)), self.tempColor[4]});
				
				colorpicker:close();
				
			end);
			
			self.uisConnection = utility:connect(userInputService.InputEnded, function(input, gpe)
				
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					
					if colorDrag then
						
						colorDrag:Disconnect();
						colorDrag = nil;
						
					end;
					
					if hueDrag then

						hueDrag:Disconnect();
						hueDrag = nil;

					end;
					
					if transparencyDrag then

						transparencyDrag:Disconnect();
						transparencyDrag = nil;

					end;
					
				end;
				
			end);
			
			self.drop = drop;
			
			self:update();
			
		end;
		
		function colorpicker:close()
			
			self.drop:Destroy();
			self.drop = nil;
			
			self.uisConnection:Disconnect();
			
		end;
		
		utility:connect(colorpicker.frame.button.MouseButton1Click, function()
			
			if not colorpicker.drop then
				
				colorpicker:open();
				
			end;
			
		end);
		
		if data.pointer then

			library.pointers[data.pointer] = colorpicker;

		end;

		colorpicker:set(colorpicker.value or {Color3.new(1, 0, 0), 0});

		self:update();
		
	end;
	
end;

local tabClass = {};
tabClass.__index = tabClass;

do
	
	function tabClass:update()
		
        self.frame.Size = UDim2.new(1 / #self.window.tabs, 0, 1, 0);
		self.frame.Position = UDim2.new((table.find(self.window.tabs, self) - 1) * (1 / #self.window.tabs), 0, 0, 0);

		if self.window.selected == self then
			
			self.frame.UIGradient.Color = ColorSequence.new(Color3.fromRGB(65, 65, 65), Color3.fromRGB(45, 45,45));
			self.window.remover.Size = UDim2.new(self.frame.Size.X.Scale, -2, 0, 1);
			self.window.remover.Position = UDim2.new(self.frame.Position.X.Scale, 1, 1, 0);
			
			for _, section in next, self.sections do
				
				section:update();
				
			end;
			
			for _, side in next, self.content:GetChildren() do
				
				if side.Name ~= "extra" then
					
					local totalSize = -5;
					local previous = 0;

					for i, section in next, side:GetChildren() do

			                        section.Position = UDim2.new(0, 4, 0, 5 + previous + (i-1) * 15);
			                        previous += section.AbsoluteSize.Y;

						totalSize += section.Size.Y.Offset + 15;
						
					end;
					
					side.CanvasSize = UDim2.new(0, 0, 0, math.max(totalSize, 0));
					
				end;
				
			end;
			
			self.content.Visible = true;
			
		else
			
			self.frame.UIGradient.Color = ColorSequence.new(Color3.fromRGB(45, 45, 45), Color3.fromRGB(45, 45,45));

			self.content.Visible = false;
			
		end;
		
	end;
	
	function tabClass:section(data)
		
		local sectionFrame = section:Clone();
		sectionFrame.Parent = self.content[data.side == 0 and "left" or "right"];
		sectionFrame.title.Text = data.title or "section";
		
		local offset = 5;
		
		for _, section in next, sectionFrame.Parent:GetChildren() do
			
			if section ~= sectionFrame then
				
				offset += section.Size.Y.Offset + 15;
				
			end;
			
		end;
		
		sectionFrame.Position = UDim2.new(0, 4, 0, offset);
		
		for _, child in next, sectionFrame:GetChildren() do
			
			if child:IsA("Frame") and not table.find({"bg", "accent"}, child.Name) then
				
				child:Destroy();
				
			end;
			
		end;
		
		local section = setmetatable({title = sectionFrame.title.Text, tab = self, frame = sectionFrame, side = data.side or 1, size = data.size}, sectionClass);
		
		table.insert(self.sections, section);
		
		return section;
		
	end;
	
end;

function library:new(data)
	
	local screenGui = Instance.new("ScreenGui", game:GetService("CoreGui"));
	screenGui.ResetOnSpawn = false;
	
	local main = allbot.main:Clone();
	main.Visible = false;
	main.Parent = screenGui;
	main.title.Text = data.title or "AllBot";
	
	local content = main.content;
	
	content:ClearAllChildren();
	
	local tabs = main.tabs;
	tabs.tab:Destroy();
	
	local window = {frame = main, remover = tabs.remover, title = main.title.Text, state = false, toggling = false, tabs = {}};
	
	local dragConnection;
	local delta = Vector2.zero;
	
	utility:connect(userInputService.InputBegan, function(input, gpe)

		if input.UserInputType == Enum.UserInputType.MouseButton1 and utility:overInstance(main.title) and not dragConnection then

			delta = main.title.AbsolutePosition - utility:mouseLocation();

			dragConnection = utility:connect(runService.RenderStepped, function()

				main.Position = utility:vector2ToUDim2(utility:mouseLocation() + delta);

			end);

		elseif input.UserInputType == Enum.UserInputType.Keyboard then

			if input.KeyCode == library.toggle_key then

				window:toggle();

			end;

		end;

	end);
	
	utility:connect(userInputService.InputEnded, function(input, gpe)

		if input.UserInputType == Enum.UserInputType.MouseButton1 and dragConnection then

			dragConnection:Disconnect();
			dragConnection = nil;

		end;

	end);
	
	function window:update()
		
		for _, tab in next, self.tabs do
			
			tab:update();
			
		end;
		
	end;
	
	function window:select(tab)
		
		self.selected = tab;
		
		self:update();
		
	end;
	
	function window:tab(data)
		
		local tabFrame = tab:Clone();
		tabFrame.Parent = window.frame.tabs;
		tabFrame.title.Text = data.title or "tab";
		tabFrame.Size = UDim2.new(1 / (#window.tabs + 1), 0, 1, 0);
		tabFrame.Position = UDim2.new(#window.tabs * (1 / (#window.tabs + 1)), 0, 0, 0);
		
		local content = Instance.new("Frame", window.frame.content);
		content.Name = tabFrame.title.Text;
		content.BackgroundTransparency = 1;
		content.Size = UDim2.new(1, 0, 1, 0);
		
		for _, part in next, {left, right, extra} do
			
			local clone = part:Clone();
			clone:ClearAllChildren();
			clone.Parent = content;
			
		end;
		
		local tab = setmetatable({sections = {}, window = window, frame = tabFrame, content = content}, tabClass);
		
		table.insert(window.tabs, tab);
		
		utility:connect(tabFrame.button.MouseButton1Click, function()

			window:select(tab);

		end);

        window:update();
		
		return tab;
		
	end;
	
	function window:toggle()
		
		if self.toggling then
			return;
		end;
		
		tweenService:Create(self.frame.UIScale, TweenInfo.new(0.3, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), {Scale = self.state and 0 or library.scale}):Play();
		
		self.state = not self.state;
		
		self.toggling = true;
		
		if not self.frame.Visible then

			self.frame.Visible = true;

		end;
		
		task.delay(0.3, function()
			
			self.toggling = false;
			
			if self.frame.UIScale.Scale == 0 then
				
				self.frame.Visible = false;
				
			end;
			
		end);
		
	end;
	
	function window:init()
		
		self.frame.UIScale.Scale = 0;
		
		self.frame.Position = UDim2.new(0.5, -self.frame.Size.X.Offset / 2, 0.5, -self.frame.Size.Y.Offset / 2);
		
        for _, image in next, self.frame:GetDescendants() do

            if image:IsA("ImageLabel") and library.assets[image.Image] ~= nil then

                image.Image = library.assets[image.Image];

            end;

        end;

		self:select(self.tabs[1]);
		self:toggle();
		
	end;
	
	return window;
	
end;

return library;
