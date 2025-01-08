local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Robojini/Tuturial_UI_Library/main/UI_Template_1"))()
local plr = game:GetService("Players").LocalPlayer
local gp = plr.ReplicatedData.gamepasses
local Window = Library.CreateLib("Free Gamepasses by urothebest", "RJTheme1")
local Tab = Window:NewTab("Gamepasses")
local Section = Tab:NewSection("Gamepasses")
Section:NewButton("Skip Spins", "Free Skip Spins Gamepass", function()
    local gps = Instance.new("BoolValue", gp)
    gps.Name = 259500454
    gps.Value = true
end)

Section:NewButton("Innate Slot 3", "Free Innate Slot 3 Gamepass", function()
    local gps = Instance.new("BoolValue", gp)
    gps.Name = 77102481
    gps.Value = true
end)

Section:NewButton("Innate Slot 4", "Free Innate Slot 4 Gamepass", function()
    local gps = Instance.new("BoolValue", gp)
    gps.Name = 77102528
    gps.Value = true
end)

Section:NewButton("Heavenly Restriction", "Free Heavenly Restriction Gamepass", function()
    local gps = Instance.new("Tool", gp.Parent.Parent.Backpack)
    gps.Name = "Heavenly Restriction"
	gp.Parent.Parent.ReplicatedData.masteries["Heavenly Restriction"].level.Value = 500
end)
