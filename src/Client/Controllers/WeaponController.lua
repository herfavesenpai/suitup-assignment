--[[
    WeaponController.lua
    Author: Aaron (se_yai)

    Description: Manages visual for weapon equip
]]

local PlayerScripts = game.Players.LocalPlayer:WaitForChild("PlayerScripts")
local Modules = PlayerScripts:WaitForChild("Modules")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local WeaponController = Knit.CreateController { Name = "WeaponController" }


function WeaponController:KnitStart()
    
end


function WeaponController:KnitInit()
    
end


return WeaponController