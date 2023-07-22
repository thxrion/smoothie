do

local vector3D = require("vector3D")

function getCharCoordinates3D(...)
      return vector3D(getCharCoordinates(...))
end

local PROCESS_LINE_OF_SIGHT_OPTIONS = {
      CHECK_IF_SOLID = true,
      VEHICLES = true,
      PEDS = true,
      OBJECTS = true,
      PARTICLES = false,
      SEE_THROUGH_OBJECTS = false,
      IGNORE_SOME_OBJECTS = false,
      OBJECTS_YOU_CAN_SHOOT_THROUGH = false,
}

function processLine(origin, target, options)
      options = options or PROCESS_LINE_OF_SIGHT_OPTIONS

      return processLineOfSight(
            origin.x, origin.y, origin.z,
            target.x, target.y, target.z,
            options.CHECK_IF_SOLID,
            options.VEHICLES,
            options.PEDS,
            options.OBJECTS,
            options.PARTICLES,
            options.SEE_THROUGH_OBJECTS,
            options.IGNORE_SOME_OBJECTS,
            options.OBJECTS_YOU_CAN_SHOOT_THROUGH
      )
end

function isPedInRange(ped, range)
      local localCoordinates = getCharCoordinates3D(PLAYER_PED)
      local pedCoordinates = getCharCoordinates3D(ped)

      local distance = getDistanceBetweenCoords3d(
            localCoordinates.x, localCoordinates.y, localCoordinates.z,
            pedCoordinates.x, pedCoordinates.y, pedCoordinates.z
      )

      return distance <= range
end

function doesPlayerHaveSameColor(playerId)
      local _, localPlayerId = sampGetPlayerIdByCharHandle(PLAYER_PED)
      return sampGetPlayerColor(playerId) == sampGetPlayerColor(localPlayerId)
end

function clamp(value, min, max)
      if value < min then
            return min
      end

      if value > max then
            return max
      end

      return value
end

end
