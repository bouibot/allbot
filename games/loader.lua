local list = {
    [111958650] = "arsenal";
};

local foundGame = list[game.GameId];

assert(foundGame, "Game not supported.");

loadstring(game:HttpGet(string.format("https://raw.githubusercontent.com/bouibot/allbot/main/games/%s.lua", foundGame)))();
