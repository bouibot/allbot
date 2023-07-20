local main = game:GetObjects("rbxassetid://14116839989")[1];
local scale = Instance.new("UIScale", main.main);
scale.Scale = 0;

local tweenService = game:GetService("TweenService");

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

local loader = {visible = false, scale = scale, frame = main.main};

do

    local supported = {
        [111958650] = "arsenal";
        [115797356] = "cbro";
    };
    
    function loader:toggle()

        tweenService:Create(self.scale, TweenInfo.new(0.3, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), {Scale = self.visible and 0 or 1}):Play();

        if self.visible then

            task.delay(0.3, function()
                
                self.frame.Visible = false;

            end);

        else

            self.frame.Visible = true;

        end;

        self.visible = not self.visible;

    end;

    function loader:start()
        
        -- // fake delays fuck off

        self.frame.data.Text = "getting data";

        task.wait(0.45);

        self.frame.data.Text = "got data";

        task.wait(0.2);

        local foundGame = supported[game.GameId];

        if foundGame then
            
            self.frame.data.Text = "found game";

            task.wait(0.3);

        else

            self.frame.data.Text = "not supported";

            task.wait(1.5);

        end;

        self:toggle();

        task.delay(0.3, function()
            
            self.frame.Parent:Destroy();

            if foundGame ~= nil then
                
                loadstring(game:HttpGet(string.format("https://raw.githubusercontent.com/bouibot/allbot/main/games/%s.lua", foundGame)))();

            end;

        end);

    end;

    function loader:init()
        
        self.frame.image.Image = get_custom_asset("allbot/assets/allbot_icon.png") -- // if it doesnt work, i dont care;

        self.frame.Parent.Parent = game:GetService("CoreGui");
        self.frame.Position = UDim2.new(0.5, -self.frame.Size.X.Offset / 2, 0.5, -self.frame.Size.Y.Offset / 2);

        self:toggle();
        self:start();

    end;

end;

loader:init();
