function arrayForeach(array, callback)
      for i = 1, #array do
            local callResult = callback(array[i], i)

            if callResult then
                  return callResult
            end
      end
end

function arrayFind(haystack, needle)
      for i = 1, #haystack do
            if haystack[i] == needle then
                  return true
            end
      end

      return false
end

local processLineOfSightOptions = {
      checkIfSolid = true,
      vehicles = true,
      pedestrians = false,
      objects = true,
      particles = false,
      seeThroughObjects = false,
      ignoreSomeObjects = false,
      objectsYouCanShootThrough = false,
}

function isPointInLineOfSight(point, options)
      options = options or processLineOfSightOptions

      local camera = vector3D(getActiveCameraCoordinates())

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
