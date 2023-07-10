require("moonloader")
-- you might wonder, why require("mimgui") and not even use it?
-- try removing the line, you'll get a
-- GTA\moonloader\lib\mimgui\init.lua:77: attempt to call field 'ImFontGlyphRangesBuilder' (a nil value)
-- for some unknown reason
require("mimgui")

-- @import <./modules/common.lua>
-- @import <./modules/bone.lua>
-- @import <./modules/camera.lua>
-- @import <./modules/weapon.lua>

-- @import <./modules/config.lua>

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

      local weaponConfig = config.getWeaponConfig()
      local vehicles = getAllVehicles()

      for i = 1, #vehicles do
            local driver = getDriverOfCar(vehicles[i])

            if not isPedValidAsTarget(driver) then
                  goto continue
            end

            local head = bone.getHeadPosition3D(driver)

            if config.shouldPedBeInLineOfSight[0] and not camera.isPointInLineOfSight(head) then
                  goto continue
            end

            local distance = camera.getScreenDistanceBetweenCrosshairAndPoint3D(head)

            if distance <= weaponConfig.radius[0] and distance < minDistance then
                  minDistance = distance
                  coordinates = head
            end

            ::continue::
      end

      return coordinates
end

local function searchForPedClosestValidBone(ped, minDistance)
      local weaponConfig = config.getWeaponConfig()

      local localMinDistance = minDistance
      local coordinates = nil

      for j = 1, #config.bones do
            local bone = bone.getBonePosition3D(ped, config.bones[j])

            if config.shouldPedBeInLineOfSight[0] and not camera.isPointInLineOfSight(bone) then
                  goto continue
            end

            local distance = camera.getScreenDistanceBetweenCrosshairAndPoint3D(bone)

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

      local pedestrians = getAllChars()

      for i = 1, #pedestrians do
            local ped = pedestrians[i]

            if isPedValidAsTarget(ped) and not isCharInAnyCar(ped) then
                  minDistance, coordinates = searchForPedClosestValidBone(ped, minDistance)
            end
      end

      return coordinates
end

local function searchForTarget()
      local target = nil

      if config.areDriversPrioritized[0] then
            target = searchForTargetAmongDrivers()
      end

      if not target then
            target = searchForTargetAmongPedestrians()
      end

      return target
end

local function renderDebugRadiuses()
      local x, y = camera.getCrosshairM16Coordinates2D()

      for weaponType, weaponTypeId in pairs(weapon.Type) do
            local weaponConfig = config.weaponTypeSpecific[weaponTypeId]

            local diameter =  weaponConfig.radius[0] * 2
            renderDrawPolygon(x, y, diameter, diameter, 40, 0, 0x30FFFFFF)
      end
end

local function onEveryFrame()
      if config.isWindowOpen[0] then
            renderDebugRadiuses()
      end

      if not camera.isAimingFirstPerson() and not camera.isAimingThirdPerson() then
            return
      end

      if not weapon.getType() then
            return
      end

      local weaponConfig = config.getWeaponConfig()

      weapon.setSpread(weaponConfig.spread[0])

      if config.doesAimingRequireFireButtonPress[0] and not isKeyDown(VK_LBUTTON) then
            return
      end

      local target = searchForTarget()

      if not target then
            return
      end

      camera.moveCrosshairTowardsPoint(target, weaponConfig.smoothness[0])
end

function onScriptTerminate(target)
	if target ~= script.this then
            return
      end

      weapon.resetSpread()
end

function main()
      repeat wait(0) until isSampAvailable()
      config.initWindow()

      while true do
            wait(0)
            onEveryFrame()
      end
end
