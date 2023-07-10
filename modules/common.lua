do

local vector3D = require("vector3D")

function getCharCoordinates3D(...)
      return vector3D(getCharCoordinates(...))
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
