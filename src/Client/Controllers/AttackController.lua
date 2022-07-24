--[[
    AttackController.lua
    Author: Aaron (se_yai)

    Description: Manage player spawning and interactions with the server involving data
]]

local PlayerScripts = game.Players.LocalPlayer:WaitForChild("PlayerScripts")
local Modules = PlayerScripts:WaitForChild("Modules")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local AttackController = Knit.CreateController { Name = "AttackController" }


function AttackController:KnitStart()
    
end


function AttackController:KnitInit()
    
end


return AttackController