-- TODO: rename all the enums properly
-- TODO: add other types of guns and map through them
-- TODO: limit inputs

local ffi = require("ffi")
local vector3D = require("vector3d")
local imgui = require("mimgui")
local windowsMessages = require("windows.message")

local camera = require("cheat.camera")
local weapon = require("cheat.weapon")
local bones = require("cheat.bones")


local configWindowState = imgui.new.bool(false)
local config = {
      toggleConfigurationMenuKey = 0x5A,

      isEnabled = imgui.new.bool(true),
      doesAimingRequireFireButtonPress = imgui.new.bool(false),
      areDriversPrioritized = imgui.new.bool(true),
      shouldPedBeInLineOfSight = imgui.new.bool(true),
      shouldPedBeInRange = imgui.new.bool(false),
      shouldPedHaveOtherColor = imgui.new.bool(true),

      weaponTypeSpecific = {
            [weapon.types.LIGHT] = {
                  radius = imgui.new.int(40),
                  smoothness = imgui.new.float(1),
                  spread = imgui.new.float(100),
            },
            [weapon.types.HEAVY] = {
                  radius = imgui.new.int(15),
                  smoothness = imgui.new.float(1),
                  spread = imgui.new.float(100),
            },
      },
}


local processLineOfSightOptions = {
      checkIfSolid = true,
      vehicles = true,
      pedestrians = true,
      objects = true,
      particles = false,
      seeThroughObjects = false,
      ignoreSomeObjects = false,
      objectsYouCanShootThrough = false,
}

local function isPointInLineOfSight(point, options)
      options = options or processLineOfSightOptions

      local camera = camera.getCoordinates3D()

      return processLineOfSight(
            camera.x, camera.y, camera.z,
            point.x, point.y, point.z,
            options.checkIfSolid,
            options.vehicles,
            options.pedestrians,
            options.particles,
            options.seeThroughObjects,
            options.ignoreSomeObjects,
            options.objectsYouCanShootThrough
      )
end

local function isPedInRange(ped, range)
      local localCoordinates = vector3D(getCharCoordinates(PLAYER_PED))
      local pedCoordinates = vector3D(getCharCoordinates(ped))

      local distance = getDistanceBetweenCoords3d(
            localCoordinates.x, localCoordinates.y, localCoordinates.z,
            pedCoordinates.x, pedCoordinates.y, pedCoordinates.z
      )

      return distance <= range
end

local function doesPlayerHaveSameColor(playerId)
      local _, localPlayerId = sampGetPlayerIdByCharHandle(PLAYER_PED)
      return sampGetPlayerColor(playerId) == sampGetPlayerColor(localPlayerId)
end

local function getScreenDistanceBetweenCrosshairAndPoint3D(point)
      local pointX, pointY = convert3DCoordsToScreen(point.x, point.y, point.z)

      if camera.isAimingFirstPerson() then
            local centerX, centerY = camera.getCenterOfScreenCoordinates2D()
            return getDistanceBetweenCoords2d(centerX, centerY, pointX, pointY)
      end

      local crosshairX, crosshairY = camera.getCrosshairM16Coordinates2D()

      return getDistanceBetweenCoords2d(crosshairX, crosshairY, pointX, pointY)
end

local function isPedValidAsTarget(ped)
      if not doesCharExist(ped) then
            return false
      end

      if ped == PLAYER_PED then
            return false
      end

      if isCharDead(ped) then
            return false
      end

      if not isCharOnScreen(ped) then
            return false
      end

      local hasId, playerId = sampGetPlayerIdByCharHandle(ped)

      if not hasId then
            return false
      end

      if config.shouldPedHaveOtherColor[0] and doesPlayerHaveSameColor(playerId) then
            return false
      end

      if config.shouldPedBeInRange[0] and getDistanceToPed(ped) > weapon.getRange() then
            return false
      end

      return true
end

local function searchForTargetAmongDrivers()
      local coordinates = nil
      local minDistance = math.huge

      local weaponType = weapon.getType()
      local vehicles = getAllVehicles()

      for i = 1, #vehicles do
            local driver = getDriverOfCar(vehicles[i])

            if not isPedValidAsTarget(driver) then
                  goto continue
            end

            local head = bones.getHeadPosition3D(driver)

            if config.shouldPedBeInLineOfSight[0] and not isPointInLineOfSight(head) then
                  goto continue
            end

            local distance = getScreenDistanceBetweenCrosshairAndPoint3D(head)

            if distance <= config.weaponTypeSpecific[weaponType].radius[0] and distance < minDistance then
                  minDistance = distance
                  coordinates = head
            end

            ::continue::
      end

      return coordinates
end

local function searchForPedClosestValidBone(ped, minDistance)
      local weaponType = weapon.getType()
      local weaponConfig = config.weaponTypeSpecific[weaponType]

      local localMinDistance = minDistance
      local coordinates = nil

      for j = 1, #bones.list do
            local bone = bones.getBonePosition3D(ped, bones.list[j])

            if config.shouldPedBeInLineOfSight[0] and not isPointInLineOfSight(bone) then
                  goto continue
            end

            local distance = getScreenDistanceBetweenCrosshairAndPoint3D(bone)

            if distance <= weaponConfig.radius[0] and distance < localMinDistance then
                  localMinDistance = distance
                  coordinates = bone
            end

            ::continue::
      end

      return localMinDistance, coordinates
end

local function searchForTargetAmongPedestrians()
      local minDistance = math.huge
      local coordinates = nil

      local weaponType = weapon.getType()
      local pedestrians = getAllChars()

      for i = 1, #pedestrians do
            local ped = pedestrians[i]

            if isPedValidAsTarget(ped) and not isCharInAnyCar(ped) then
                  minDistance, coordinates = searchForPedClosestValidBone(ped, minDistance)
            end
      end

      return coordinates
end

local function onEveryFrame()
      if not camera.isAimingFirstPerson() and not camera.isAimingThirdPerson() then
            return
      end
      
      if not weapon.isAimable() then
            return
      end

      local weaponType = weapon.getType()
      local weaponConfig = config.weaponTypeSpecific[weaponType]

      local target = nil

      if config.areDriversPrioritized[0] then
            target = searchForTargetAmongDrivers()
      end

      if not target then
            target = searchForTargetAmongPedestrians()
      end

      if target then
            camera.moveCrosshairTowardsPoint(target, weaponConfig.smoothness[0])
      end

      weapon.setSpread(weaponConfig.spread[0])
end

function onScriptTerminate(target)
	if target ~= script.this then
            return
      end

      weapon.resetSpread()
end

function onWindowMessage(message, wparam)
      if message ~= windowsMessages.WM_KEYDOWN and message ~= windowsMessages.WM_SYSKEYDOWN then
            return
      end

      if sampIsChatInputActive() or isSampfuncsConsoleActive() or sampIsDialogActive() then
            return
      end

      if wparam ~= config.toggleConfigurationMenuKey then
            return
      end

      configWindowState[0] = not configWindowState[0]
end

local function getConfigWindowState()
      return configWindowState[0]
end

local function onDrawConfigurationWindow()
      imgui.Begin("Configuration", configWindowState, imgui.WindowFlags.AlwaysAutoResize)

      imgui.Checkbox("Enabled", config.isEnabled)

      imgui.Text("Handguns")
      imgui.InputInt("Radius##handguns", config.weaponTypeSpecific[weapon.types.LIGHT].radius)
      imgui.InputFloat("Smoothness##handguns", config.weaponTypeSpecific[weapon.types.LIGHT].smoothness)

      imgui.Text("Rifles")
      imgui.InputInt("Radius##rifles", config.weaponTypeSpecific[weapon.types.HEAVY].radius)
      imgui.InputFloat("Smoothness##rifles", config.weaponTypeSpecific[weapon.types.HEAVY].smoothness)


      imgui.Checkbox("Lock only if `fire` is pressed", config.doesAimingRequireFireButtonPress)
      imgui.Checkbox("Lock at drivers first", config.areDriversPrioritized)
      imgui.Checkbox("Lock only at ones in line of sight", config.shouldPedBeInLineOfSight)
      imgui.Checkbox("Lock only at ones in range of weapon", config.shouldPedBeInRange)
      imgui.Checkbox("Lock only at ones of other color", config.shouldPedHaveOtherColor)

      
      imgui.Text("Increased weapon accuracy")

      imgui.SliderFloat("Handguns accuracy %", config.weaponTypeSpecific[weapon.types.LIGHT].spread, 0, 100)
      imgui.SliderFloat("Rifles accuracy %", config.weaponTypeSpecific[weapon.types.HEAVY].spread, 0, 100)

      imgui.Button("Just a good ol` button", imgui.ImVec2(120, 20))

      imgui.End()
end

local function onInit()
      imgui.OnFrame(getConfigWindowState, onDrawConfigurationWindow)
end

function main()
      onInit()

      while true do
            wait(0)
            onEveryFrame()
      end
end