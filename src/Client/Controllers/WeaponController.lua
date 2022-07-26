--[[
    WeaponController.lua
    Author: Aaron (se_yai)

    Description: Manages visual for weapon equip
]]
local TweenService = game:GetService("TweenService")

local PlayerScripts = game.Players.LocalPlayer:WaitForChild("PlayerScripts")
local Modules = PlayerScripts:WaitForChild("Modules")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Assets = ReplicatedStorage:WaitForChild("Assets")
local WEAPON_BASE = Assets.Weapons:WaitForChild("KaoruBat")


local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local WaitFor = require(Packages.WaitFor)

local WeaponController = Knit.CreateController { Name = "WeaponController" }
local CharacterController

local BAT_SIZE = Vector3.new(5.296, 0.564, 0.564)
local GRIP_POS = -1.772
local BASE_POS = -0.781
local TIP_POS = 2.159
local RETURN_TWEEN_INFO = TweenInfo.new(
    0.25, Enum.EasingStyle.Back, Enum.EasingDirection.InOut
)

function WeaponController:AdjustSize(ratio)
    if self._weapon then
        -- local constraint = self._weapon
        WaitFor.Descendant(self._weapon, "MeshPart", 3):andThen(function(mesh)
            local grip = mesh.RightGripAttachment
            local base = mesh.Base
            local tip = mesh.Tip
            
            if ratio > 1 then
                mesh.Size = BAT_SIZE * ratio
                grip.Position = Vector3.new(GRIP_POS * ratio, 0, 0)
                base.Position = Vector3.new(BASE_POS * ratio, 0, 0)
                tip.Position = Vector3.new(TIP_POS * ratio, 0, 0)

            else
                TweenService:Create(mesh, RETURN_TWEEN_INFO, {
                    Size = BAT_SIZE
                }):Play()

                -- reset attachments
                TweenService:Create(grip, RETURN_TWEEN_INFO, {
                    Position = Vector3.new(GRIP_POS, 0, 0)
                }):Play()
                TweenService:Create(base, RETURN_TWEEN_INFO, {
                    Position = Vector3.new(BASE_POS, 0, 0)
                }):Play()
                TweenService:Create(tip, RETURN_TWEEN_INFO, {
                    Position = Vector3.new(TIP_POS, 0, 0)
                }):Play()
            end
        end):catch(function()
            print("could not get bat mesh part")
        end)
    else
        print("no weapon to adjust")
    end
end

function WeaponController:EnableTrail(state)

    if state or not self._trailActive then
        self._weapon:FindFirstChild("Trail").Enabled = true
        task.delay(0.7, function()
            self:EnableTrail(false)
        end)
    else
        self._weapon:FindFirstChild("Trail").Enabled = false
    end

    self._trailActive = state or not self._trailActive
end

function WeaponController:KnitStart()
    CharacterController.CharacterAddedEvent:Connect(function(character)
        -- attach weapon
        WaitFor.Descendant(character, "RightGripAttachment", 3):andThen(function(attach)
            local newWeapon = WEAPON_BASE:Clone()
            local rc = Instance.new("RigidConstraint")
            rc.Attachment0 = attach
            rc.Attachment1 = newWeapon:FindFirstChild("RightGripAttachment", true)
            rc.Parent = newWeapon
            newWeapon.Parent = character
            rc.Enabled = true

            self._weapon = newWeapon
            print("Attached weapon to:", attach)
        end)
    end)
end


function WeaponController:KnitInit()
    self._trailActive = false
    CharacterController = Knit.GetController("CharacterController")
end


return WeaponController