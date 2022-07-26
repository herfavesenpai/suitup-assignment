--[[
    WeaponController.lua
    Author: Aaron (se_yai)

    Description: Manages visual for weapon equip
]]

local PlayerScripts = game.Players.LocalPlayer:WaitForChild("PlayerScripts")
local Modules = PlayerScripts:WaitForChild("Modules")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Assets = ReplicatedStorage:WaitForChild("Assets")
local WEAPON_BASE = ReplicatedStorage.Assets.Weapons:WaitForChild("KaoruBat")


local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local WeaponController = Knit.CreateController { Name = "WeaponController" }
local CharacterController

function WeaponController:EnableTrail(state)

    if state or not self._trailActive then
        self._weapon:FindFirstChild("Trail").Enabled = true
    else
        self._weapon:FindFirstChild("Trail").Enabled = false
    end

    self._trailActive = state or not self._trailActive
end

function WeaponController:KnitStart()
    CharacterController.CharacterAddedEvent:Connect(function(character)
        -- attach weapon
        task.wait()
        local newWeapon = WEAPON_BASE:Clone()
        local rc = Instance.new("RigidConstraint")
        rc.Attachment0 = character.RightHand:FindFirstChild("RightGripAttachment")
        rc.Attachment1 = newWeapon:FindFirstChild("RightGripAttachment", true)
        rc.Parent = newWeapon
        newWeapon.Parent = character
        rc.Enabled = true

        self._weapon = newWeapon
    end)
end


function WeaponController:KnitInit()
    self._trailActive = false
    CharacterController = Knit.GetController("CharacterController")
end


return WeaponController