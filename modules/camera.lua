local vector3D = require("vector3d")
local SAMemory = require("SAMemory")
SAMemory.require("CCamera")

local camera = {}

local THIRD_PERSON_AIMING_MODES = {
      [0x35] = "MODE_AIMWEAPON",
      [0x37] = "MODE_AIMWEAPON_FROMCAR",
      [0x41] = "MODE_AIMWEAPON_ATTACHED",
}

local FIRST_PERSON_AIMING_MODES = {
      [0x7] = "MODE_SNIPER",
      [0x8] = "MODE_ROCKETLAUNCHER",
      [0x33] = "MODE_ROCKETLAUNCHER_HS",
}

local PROCESS_LINE_OF_SIGHT_OPTIONS = {
      checkIfSolid = true,
      vehicles = true,
      pedestrians = true,
      objects = true,
      particles = false,
      seeThroughObjects = false,
      ignoreSomeObjects = false,
      objectsYouCanShootThrough = false,
}

function camera.getCoordinates3D()
      return vector3D(getActiveCameraCoordinates())
end

function camera.isPointInLineOfSight(point, options)
      options = options or PROCESS_LINE_OF_SIGHT_OPTIONS

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

function camera.getScreenDistanceBetweenCrosshairAndPoint3D(point)
      local pointX, pointY = convert3DCoordsToScreen(point.x, point.y, point.z)

      if camera.isAimingFirstPerson() then
            local centerX, centerY = camera.getCenterOfScreenCoordinates2D()
            return getDistanceBetweenCoords2d(centerX, centerY, pointX, pointY)
      end

      local crosshairX, crosshairY = camera.getCrosshairM16Coordinates2D()
      return getDistanceBetweenCoords2d(crosshairX, crosshairY, pointX, pointY)
end

function camera.isAimingFirstPerson()
      local cameraMode = tonumber(SAMemory.camera.aCams[0].nMode)
      return FIRST_PERSON_AIMING_MODES[cameraMode]
end

function camera.isAimingThirdPerson()
      local cameraMode = tonumber(SAMemory.camera.aCams[0].nMode)
      return THIRD_PERSON_AIMING_MODES[cameraMode]
end

function camera.getCenterOfScreenCoordinates2D()
      local resolutionX, resolutionY = getScreenResolution()
      return resolutionX * 0.5, resolutionY * 0.5
end

function camera.getCrosshairM16Coordinates2D()
      local resolutionX, resolutionY = getScreenResolution()
      return resolutionX * 0.5299999714, resolutionY * 0.4
end

function camera.convertScreenCoordinatesToWorld3D(x, y)
      return vector3D(convertScreenCoordsToWorld3D(x, y, 5))
end

local function convertCartesianCoordinatesToSpherical(point)
      local camera = camera.getCoordinates3D()
      local vector = point - camera

      local r = vector:length()
      local phi = math.atan2(vector.y, vector.x)
      local theta = math.acos(vector.z / r)

      if phi > 0 then
            phi = phi - math.pi
      else
            phi = phi + math.pi
      end
      theta = math.pi / 2 - theta

      return phi, theta
end

local function getCameraRotation()
      local theCamera = SAMemory.camera
      local phi = theCamera.aCams[0].fHorizontalAngle
      local theta = theCamera.aCams[0].fVerticalAngle

      return phi, theta
end

local function setCameraRotation(phi, theta)
      local theCamera = SAMemory.camera

      theCamera.aCams[0].fHorizontalAngle = phi
      theCamera.aCams[0].fVerticalAngle = theta
end

local function getCrosshairRotation()
      if camera.isAimingFirstPerson() then
            return getCameraRotation()
      end

      local crosshairOnScreenX, crosshairOnScreenY = camera.getCrosshairM16Coordinates2D()
      local crosshair = camera.convertScreenCoordinatesToWorld3D(crosshairOnScreenX, crosshairOnScreenY)

      return convertCartesianCoordinatesToSpherical(crosshair)
end

function camera.moveCrosshairTowardsPoint(point, k)
      local pointPhi, pointTheta = convertCartesianCoordinatesToSpherical(point)
      local cameraPhi, cameraTheta = getCameraRotation()
      local crosshairPhi, crosshairTheta = getCrosshairRotation()

      cameraPhi = cameraPhi + k * (pointPhi - crosshairPhi)
      cameraTheta = cameraTheta + k * (pointTheta - crosshairTheta)

      setCameraRotation(cameraPhi, cameraTheta)
end

return camera
