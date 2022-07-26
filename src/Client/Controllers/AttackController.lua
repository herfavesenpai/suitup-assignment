--[[
    AttackController.lua
    Author: Aaron (se_yai)

    Description: Manage player spawning and interactions with the server involving data
]]
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = game.Players.LocalPlayer
local PlayerScripts = game.Players.LocalPlayer:WaitForChild("PlayerScripts")
local Modules = PlayerScripts:WaitForChild("Modules")


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local SpatialCast = require(Shared.SpatialCast)
local ImpulseFling = require(Shared.ImpulseFling)

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Maid = require(Packages.Maid)
local WaitFor = require(Packages.WaitFor)

local AttackController = Knit.CreateController { Name = "AttackController" }

--== KNIT SINGLETON DECLARATIONS ==--
local CharacterController, WeaponController
local MobService

--== CONSTANTS ==--
local MIN_CHARGE_TIME = 7/60 -- in seconds
local MAX_CHARGE_TIME = 1 -- in seconds
local MAX_CHARGE_HOLD = 2.5
local MAX_COOLDOWN = 1.1
local MIN_COOLDOWN = 0.2


local BASE_HITBOX = {
    Vector2.new(3, 5), -- size
    5, -- range
    0.3
}

local BASE_DAMAGE = 10
local MAX_CHARGE_MULT = 10

function AttackController:ProcessAttack(chargeTime)
    -- could *technically* be abused by sending your own charge time rather than the actual, but 
    -- this is setup in the event that self._chargeTime is reset before this method is called

    -- distinguish between instant attack or charged attack
    local animName = "ChargeSlam"
    local chargeRatio = 1
    if chargeTime <= MIN_CHARGE_TIME then
        -- perform instant attack
            -- play animation
            -- calculate hit
        animName = "UnchargedAttack"
    else
        chargeRatio += chargeTime / MAX_CHARGE_TIME
    end

    WeaponController:EnableTrail(true)
    CharacterController:PlayAnimation(animName)

    local activeTime = BASE_HITBOX[3] * chargeRatio

    local thisMaid = Maid.new()

    local hits = {}
    thisMaid:Add(self.Hitbox.OnHit:Connect(function(mob)
        table.insert(hits, mob)
        mob:SetAttribute("LastRatio", chargeRatio)
    end))

    task.wait(7/60)
    self.Hitbox:Activate(
        Vector2.new(BASE_HITBOX[1].X * chargeRatio * 2, BASE_HITBOX[1].Y * chargeRatio * 0.6),
        BASE_HITBOX[2] * chargeRatio,
        "Z",
        activeTime
    )

    task.delay(activeTime, function()
        MobService:DamageMobs(hits, chargeRatio)
        WeaponController:AdjustSize(1)
        thisMaid:Destroy()
    end)
end

function AttackController:KnitStart()
    -- if released < 7 frames, use instant swing
    -- else use charged swing

    local validInputs = {
        Types = {
            Enum.UserInputType.MouseButton1
        },
        KeyCodes = {
            Enum.KeyCode.E
        }
    }
    local function validateInput(input)
        for _, v in validInputs.Types do
            if input.UserInputType == v then
                return true, v
            end
        end

        for _, k in validInputs.KeyCodes do
            if input.KeyCode == k then
                return true, k
            end
        end

        return false
    end

    -- listen for valid input and not on cooldown
    UserInputService.InputBegan:Connect(function(input)
        -- check for attack cooldown
        if self._attackCooldown > 0 then
            return
        end
        
        local success, curInput = validateInput(input)
        if success then
            self._isCharging = true
            self._lastInput = curInput
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        local success, curInput = validateInput(input)
        if self._isCharging and success and curInput == self._lastInput then
            self._isCharging = false
        end
    end)

    -- setup trail end listeners
    CharacterController.CharacterAddedEvent:Connect(function(character)
        for _, animName in {"UnchargedAttack", "ChargeSlam"} do
            local track = CharacterController._animationPlayer:GetTrack(animName)
            self._maid:Add(track.Stopped:Connect(function()
                WeaponController:EnableTrail(false)
            end))
        end

        WaitFor.Child(character, "HumanoidRootPart"):andThen(function(root)
            self.Hitbox = SpatialCast.new(root, false)
        end)
    end)

    -- update loop for attack charging
    RunService.Heartbeat:Connect(function(dt)
        if self._attackCooldown > 0 then
            self._attackCooldown -= dt
            return
        end
        
        -- increment charge time when valid input is held
        if self._isCharging then
            self._chargeTime += dt

            -- force release after reaching MAX_CHARGE_HOLD time
            if self._chargeTime >= MAX_CHARGE_HOLD then
                self._isCharging = false
            elseif self._chargeTime > MIN_CHARGE_TIME then
                if not CharacterController._animationPlayer:GetTrack("ChargeLoop").IsPlaying then
                    CharacterController:PlayAnimation("ChargeLoop")
                end
    
                local clampedCharge = math.clamp(self._chargeTime, MIN_CHARGE_TIME, MAX_CHARGE_TIME)
                WeaponController:AdjustSize(1 + (clampedCharge / MAX_CHARGE_TIME))
            end

        -- apply charge release
        elseif not self._isCharging and self._chargeTime > 0 then
            CharacterController._animationPlayer:StopTrack("ChargeLoop")
            -- call attack method
            local clampedCharge = math.clamp(self._chargeTime, MIN_CHARGE_TIME, MAX_CHARGE_TIME)
            self:ProcessAttack(clampedCharge)

            -- place attack on cooldown based on "type" of attack, reset _chargeTime
            if self._chargeTime <= MIN_CHARGE_TIME then
                self._attackCooldown = MIN_COOLDOWN
            else
                local ratio = clampedCharge / MAX_CHARGE_TIME
                self._attackCooldown = ratio * MAX_COOLDOWN
            end

            self._chargeTime = 0
        end
    end)
end


function AttackController:KnitInit()
    -- initialize variables
    self._isCharging = false
    self._chargeTime = 0
    self._attackCooldown = 0
    self._maid = Maid.new()
    
    CharacterController = Knit.GetController("CharacterController")
    WeaponController = Knit.GetController("WeaponController")

    MobService = Knit.GetService("MobService")
end


return AttackController