local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")

local OFFSET_SCALE = 0.66
local HEIGHT_AXIS = "Y"
local BASE_HEIGHT = Vector3.new(
    3.024299621582, 6.5810575485229, 4.010778427124
)[HEIGHT_AXIS]
-- 3.024299621582, 6.5810575485229, 4.010778427124



local DEBUG_POS = false
local FORCE = math.huge

return function(instance,
    targetPosition,
    travel_time, can_float, power)
    -- easingdir = easingdir or Enum.EasingDirection.InOut
    local existingBvelo = instance:FindFirstChild("BodyPosition")
    if existingBvelo then
        existingBvelo:Destroy()
    end

    local y_force = (can_float and FORCE) or 0

    local assembly = instance:FindFirstAncestorOfClass("Model")

    local rcp = RaycastParams.new()
    rcp.FilterType = Enum.RaycastFilterType.Blacklist
    rcp.CollisionGroup = "Players"

    rcp.FilterDescendantsInstances = {assembly}

    if DEBUG_POS then
        local dbp = Instance.new("Part")
        dbp.Anchored = true
        dbp.CanCollide = false
        dbp.Size = Vector3.new(0.5, 0.5, 0.5)
        dbp.Position = targetPosition
        dbp.Parent = workspace.Runtime
        PhysicsService:SetPartCollisionGroup(dbp, "ignoreDefault")
        Debris:AddItem(dbp, 2)
    end

    local bpos = Instance.new("BodyPosition")
    bpos.MaxForce = Vector3.new(FORCE, y_force, FORCE)
	bpos.Position = targetPosition

    bpos.P *= power

    bpos.Parent = instance
    Debris:AddItem(bpos, travel_time)

    return bpos
end