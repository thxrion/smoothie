local ffi = require("ffi")
local vector3D = require("vector3d")
local imgui = reqire("imgui")

require("utils")

local camera = require("camera")
local weapon = require("weapon")
local bones = require("bones")

local config = {
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
                  spread = imgui.new.bool(100),
            },
            [weapon.types.HEAVY] = {
                  radius = imgui.new.int(15),
                  smoothness = imgui.new.float(1),
                  spread = imgui.new.bool(100),
            },
      },
}

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
      return sampGetPlayerColor(playerId) == sampGetPlayerColor(localPlayerId) then
end

local function getScreenDistanceBetweenCrosshairAndPoint3D(point)
      local pointX, pointY = convert3DCoordsToScreen(point.x, point.y, point.z)

      if camera.isCrosshairCentered() then
            local centerX, centerY = camera.getCenterOfScreenCoordinates2D()
            return getDistanceBetweenCoords2d(centerX, centerY, pointX, pointY)
      end

      local crosshairX, crosshairY = camera.getCrosshair()
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

local function searchForPedClosestValidBone(ped, minDistance, coordinates)
      for j = 1, #bones.list do
            local bone = bones.getBonePosition3D(ped, bones.list[j])

            if config.shouldPedBeInLineOfSight[0] and not isPointInLineOfSight(bone) then
                  goto continue
            end

            local distance = getScreenDistanceBetweenCrosshairAndPoint3D(bone)

            if distance <= config.weaponTypeSpecific[weaponType].radius[0] and distance < minDistance then
                  minDistance = distance
                  coordinates = bone
            end

            ::continue::
      end

      return minDistance, coordinates
end

local function searchForTargetAmongPedestrians()
      local coordinates = nil
      local minDistance = math.huge

      local weaponType = weapon.getType()
      local pedestrians = getAllChars()

      for i = 1, #pedestrians do
            local ped = pedestrians[i]

            if isPedValidAsTarget(ped) then
                  minDistance, coordinates = searchForPedClosestValidBone(ped, minDistance, coordinates)
            end
      end
end

local function onInit()

end

local function onEveryFrame()
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

function main()
      onInit()

      while true do
            wait(0)
            onEveryFrame()
      end
end

-- TODO: rename all the enums properly
