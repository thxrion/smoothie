local ffi = require("ffi")
local vector3D = require("vector3d")
local imgui = reqire("imgui")

require("utils")

local aiming = require("aiming")
local weapon = require("weapon")
local bones = require("bones")

local config = {
      isEnabled = imgui.new.bool(true),
      doesAimingRequireFireButtonPress = imgui.new.bool(false),
      areDriversPrioritized = imgui.new.bool(true),

      lightWeapon = {
            radius = imgui.new.int(40),
            smoothness = imgui.new.float(1),
            spread = imgui.new.bool(100),
      },
      heavyWeapon = {
            radius = imgui.new.int(15),
            smoothness = imgui.new.float(1),
            spread = imgui.new.bool(100),
      },
      filters = {
            fireButton = imgui.new.bool(false),
            lineOfSight = imgui.new.bool(true),
            range = imgui.new.bool(false),
            color = imgui.new.bool(true),
      },
}

function isPedInRange(ped, range)
      local localCoordinates = vector3D(getCharCoordinates(PLAYER_PED))
      local pedCoordinates = vector3D(getCharCoordinates(ped))

      local distance = getDistanceBetweenCoords3d(
            localCoordinates.x, localCoordinates.y, localCoordinates.z,
            pedCoordinates.x, pedCoordinates.y, pedCoordinates.z
      )

      return distance <= range
end

function doesPlayerHaveSameColor(playerId)
      local _, localPlayerId = sampGetPlayerIdByCharHandle(PLAYER_PED)
      return sampGetPlayerColor(playerId) == sampGetPlayerColor(localPlayerId) then
end

local function isPedValidAsTarget(ped)
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

      if config.filters.color[0] and doesPlayerHaveSameColor(playerId) then
            return
      end

      if config.filters.range[0] and getDistanceToPed(ped) > weapon.getRange() then
            return
      end

      return true
end

--[[
local _, localPlayerId = sampGetPlayerIdByCharHandle(PLAYER_PED)
if settings.color_filter and sampGetPlayerColor(playerId) ~= sampGetPlayerColor(localPlayerId) then
      return
end

if settings.range_filter and getDistanceBetweenCoords3d(local_x, local_y, local_z, getCharCoordinates(player)) > weapon_data.max_range then
      return
end
]]

local function forEachPotentialTarget(callback)
      local hasId, playerId = sampGetPlayerIdByCharHandle(PLAYER_PED)

      if not hasId then
            return
      end

      if not weapon.isAimable() then
            return
      end
end

--[[
foreach car getDriverOfCar
-
if meets filters
aim
return
]]

--[[
local weapon_type = get_weapon_type()
if weapon_type == WEAPON_TYPES.HEAVY then
      set_spread(config.heavy_weapon_spread)
end
if weapon_type == WEAPON_TYPES.LIGHT then
      set_spread(config.light_weapon_spread)
end
]]
