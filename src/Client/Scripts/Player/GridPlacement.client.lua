-- GridPlacement building client/local script
-- minhnormal

local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer
local playerScripts = localPlayer.PlayerScripts

local clientModules = playerScripts:WaitForChild("Modules")

local gridPlacementModules = clientModules.GridPlacement
local gridPlacement = require(gridPlacementModules.GridPlacement):create()

gridPlacement.placingIncrementInStuds = 0.5

local testPart = Instance.new("Part")
testPart.Name = "TestPart"
testPart.Anchored = true
testPart.Parent = workspace

local buildKeyInputs = {
    Enum.KeyCode.B
}

local function handleBuilding(_, inputState, _)
    if inputState == Enum.UserInputState.Begin then
        if gridPlacement.isPlacing then
            gridPlacement:finishPlacement()
            return
        end

        gridPlacement:startPlacement(testPart)
    end
end

ContextActionService:BindAction("Build", handleBuilding, false, table.unpack(buildKeyInputs))
