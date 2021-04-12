-- The math for Grid Placement: such as get nearest point to snap
-- minhnormal

local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer
local playerMouse = localPlayer:GetMouse()

local GridMath = {}

local function constructRaycastParams(blacklist)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = blacklist or {}
    raycastParams.IgnoreWater = true
    return raycastParams
end


function GridMath.getRayMouseHitPosition(object, placingRadius)
    local playerMouseUnitRay = playerMouse.UnitRay
    
    local playerCharacter = localPlayer.Character or localPlayer.CharacterAdded:Wait()

    local blacklist = {object, playerCharacter}
    local raycastParams = constructRaycastParams(blacklist)
    local raycastResult = workspace:Raycast(playerMouseUnitRay.Origin, playerMouseUnitRay.Direction * placingRadius, raycastParams)

    if not raycastResult then return end

    return raycastResult.Position
end


function GridMath.getSnapToCFrame(object, objectSize, placingIncrementInStuds, placingRadius)
    if not object then return end

    objectSize = objectSize or Vector3.new(1, 1, 1)
    placingIncrementInStuds = placingIncrementInStuds or 1
    placingRadius = placingRadius or 10000

    local mouseHitPosition = GridMath.getRayMouseHitPosition(object, placingRadius)
    if not mouseHitPosition then return end

    return CFrame.new(
        math.floor(mouseHitPosition.X / placingIncrementInStuds) * placingIncrementInStuds,
        mouseHitPosition.Y + objectSize.Y / 2,
        math.floor(mouseHitPosition.Z/placingIncrementInStuds) * placingIncrementInStuds
    )
end

return GridMath
