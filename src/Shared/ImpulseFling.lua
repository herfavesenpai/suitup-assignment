--!nonstrict
local DEBUG_TAG = "[" .. script.Name .. "]"

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)


local thisRandom = Random.new(os.time())

local BASE_MASS = 10.526498794556 -- DON'T CHANGE THIS!!

local HEIGHT_FACTOR = 420
local YEET_FACTOR = 420

return function(model: Model, direction: Vector3)
    if model.PrimaryPart then
        local assemblyMass = model.PrimaryPart.AssemblyMass
        local massRatio = 5 -- (assemblyMass / BASE_MASS)
        print("MASS RATIO:", massRatio)
        local adjustedHeight = HEIGHT_FACTOR * massRatio
        local adjustedYeet = YEET_FACTOR * massRatio

        -- remove any BodyMover forces before fling
        for _, v in ipairs(model.PrimaryPart:GetChildren()) do
            if v:IsA("BodyMover") then
                v:Destroy()

            end
        end

        -- reset LINEAR velocity, keep angular for funny ragdolls
        model.PrimaryPart.AssemblyLinearVelocity = Vector3.new()
        
        -- -- apply forces!
        -- model.PrimaryPart:ApplyImpulse(
        --     Vector3.new(0, adjustedHeight, 0) + (direction * adjustedYeet)
        -- )

        task.delay(1/60, function()
            local xdir = thisRandom:NextNumber(-1, 2)
            local ydir = thisRandom:NextNumber(-1, 2)
            local zdir = thisRandom:NextNumber(-1, 2)
            
            if xdir <= 0 then xdir = -1 else xdir = 1 end
            if ydir <= 0 then ydir = -1 else ydir = 1 end
            if zdir <= 0 then zdir = -1 else zdir = 1 end

            -- model.PrimaryPart:ApplyAngularImpulse(Vector3.new(
            --     xdir * adjustedYeet,
            --     ydir * adjustedYeet,
            --     zdir * adjustedYeet
            -- ))
        end)
    end
end