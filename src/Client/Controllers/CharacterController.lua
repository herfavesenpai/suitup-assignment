--[[
    CharacterController.lua
    Author: Aaron (se_yai)

    Description: Manage character state
]]
local LocalPlayer = game.Players.LocalPlayer
local PlayerScripts = game.Players.LocalPlayer:WaitForChild("PlayerScripts")
local Modules = PlayerScripts:WaitForChild("Modules")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Promisified = require(Shared.Promisified)
local AnimationPlayer = require(Shared.AnimationPlayer)

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Signal = require(Packages.Signal)

local CharacterController = Knit.CreateController { Name = "CharacterController" }

function CharacterController:PlayAnimation(trackName)
    assert(self._animationPlayer:GetTrack(trackName), "Could not find animation: " .. trackName)
    self._animationPlayer:StopAllTracks()
    task.wait()
    self._animationPlayer:PlayTrack(trackName)
end

function CharacterController:KnitStart()
    LocalPlayer.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid", true)
        -- load animations
        Promisified.WaitForChild(humanoid, "Animator"):andThen(function(animator)
            self._animator = animator
            self._animationPlayer = AnimationPlayer.new(animator)
            for _, v in ReplicatedStorage.Assets.Animations:GetChildren() do
                self._animationPlayer:WithAnimation(v, v.Name)
                print("loaded anim:", v.Name)
            end
        end):finally(function()
            self.CharacterAddedEvent:Fire(character)
        end)
    end)
end


function CharacterController:KnitInit()
    self.CharacterAddedEvent = Signal.new()
end


return CharacterController