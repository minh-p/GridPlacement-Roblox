-- GridPlacement: Determine position and request the Server placing
-- minhnormal

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local playerScripts = Players.LocalPlayer.PlayerScripts
local gridPlacementModules = playerScripts.Modules.GridPlacement

local GridMath = require(gridPlacementModules.GridMath)

local GridPlacement = {}

function GridPlacement:create(object)
    object = object or {
        isPlacing = false,
        placingRender = nil,
        placingIncrementInStuds = 1,
        placingRadius = 10000,

        ghostTransparency = 0.7,
        ghostColor = Color3.fromRGB(0, 0, 0),

        currentObject = nil
    }

    self.__index = self
    setmetatable(object, self)
    return object
end


local function transparent(object, transparency)
    if object:IsA("BasePart") then
        object.Transparency = transparency
    end

    for _, child in ipairs(object:GetChildren()) do
        child.Transparency = transparency
        transparent(child)
    end
end


local function colorize(object, color)
    if object:IsA("BasePart") then
        object.Color = color
    end

    for _, child in ipairs(object:GetChildren()) do
        child.Color = color
        color(child, color)
    end
end


function GridPlacement:createGhost()
    local currentObject = self.currentObject
    local ghost = currentObject:Clone()
    ghost.Parent = currentObject.Parent

    transparent(ghost, self.ghostTransparency)
    colorize(ghost, self.ghostColor)
    ghost.CanCollide = false

    self.currentGhost = ghost

    return ghost
end


local function getObjectSize(object)
    if object:IsA("Model") then

        if not object.PrimaryPart then
            warn("object <<model>> does not have a primary part: placing cancelled")
            return
        end

        return object:GetExtentsSize()

    elseif object:IsA("BasePart") then
        return object.Size
    else
        warn("Innapropriate object Instance Type: placing cancelled")
        return
    end
end


function GridPlacement:startPlacement(objectToPlace)
    -- Determine whethere the objectToPlace is a model with a primary part or a part.
    -- This is very important as we have to get the size and position of the object.
    
    if not typeof(objectToPlace) == "Instance" then warn("objectToPlace argument is not an instance") return end

    self.currentObject = objectToPlace
    self:createGhost()

    self.placingRender = RunService.Heartbeat:Connect(function()
        local objectToPlaceSize = getObjectSize(objectToPlace)
        if not objectToPlaceSize then return end

        if objectToPlace:IsA("Model") then
            self.currentGhost.PrimaryPart.CFrame = GridMath.getSnapToCFrame(self.currentGhost, objectToPlaceSize, self.placingIncrementInStuds, self.placingRadius)
            return
        end

        local objectToPlaceNewCFrame = GridMath.getSnapToCFrame(self.currentGhost, objectToPlaceSize, self.placingIncrementInStuds, self.placingRadius)
        if not objectToPlaceNewCFrame then return end

        self.currentGhost.CFrame = objectToPlaceNewCFrame
    end)

    self.isPlacing = true
end


function GridPlacement:finishPlacement()
    -- Add a isPlacementFinished parameter to either cancel or build (request server).
    self.placingRender:Disconnect()
    self.placingRender = nil
    self.isPlacing = false

    if not self.currentObject or not self.currentGhost then return end

    self.currentGhost:Destroy()
    self.currentGhost = nil

    self.currentObject = nil
end

return GridPlacement
