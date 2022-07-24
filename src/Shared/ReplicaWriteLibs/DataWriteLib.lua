--[[
    DataWriteLib.lua
    Author: urGirlsFaveSenpai
    Description: Write libs to process data for player profile

]]
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local Knit = require(game.ReplicatedStorage.Packages.Knit)

local Shared = game.ReplicatedStorage.Shared
local SenpaiTypes = require(Shared.SenpaiTypes)
local WeaponData = require(Shared.WeaponData)

local DEBUG_TAG = "[" .. script.Name .. "]"

-- verify these on the server and stuff
local DataWriteLib = {

    AddExp = function(replica, amount)
        replica:IncrementValue({"STATS", "EXP"}, amount)        
        replica:Write("LevelUp")

        warn(DEBUG_TAG .. " Added (" .. 
            tostring(amount) .. ") exp"
        )
    end,

    IncrementCurrency = function(replica, amount)
        replica:IncrementValue({"STATS", "Currency"}, amount)
    end,

    LevelUp = function(replica)
        local currentExp = replica.Data.STATS.EXP
        local toNext = replica.Data.STATS.expToNext
        local nextLevel = 200

        if currentExp >= toNext then
            replica:IncrementValue({"STATS", "Level"}, 1)

            -- adjust leftover exp
            local leftoverExp = math.clamp(currentExp - toNext, 0, nextLevel)
            replica:SetValue({"STATS", "EXP"}, leftoverExp)

            -- get next level cap
            -- TODO: get next level
            replica:SetValue({"STATS", "expToNext"}, nextLevel) 
        end
    end,

    AddWeaponToInv = function(replica, weapon_id): number
        local new_info: SenpaiTypes.InvWeapon = {
            ID = weapon_id;
            Stats = {
                STR = 12;
            };
            UID = HttpService:GenerateGUID();
        }

        print("added weapon to inventory")
        return replica:ArrayInsert({"Weapons"}, new_info)
    end,


    AdjustValue = function(replica, amount, dataPath)
        replica:IncrementValue(dataPath, amount)
    end
}

return DataWriteLib