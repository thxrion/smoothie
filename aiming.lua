local vector3D = require("vector3d")
local SAMemory = require("SAMemory")
SAMemory.require("CCamera")

local module = {}

local CENTERED_CROSSHAIR_AIMING_MODES = {
      [0x7] = "MODE_SNIPER",
      [0x8] = "MODE_ROCKETLAUNCHER",
      [0x33] = "MODE_ROCKETLAUNCHER_HS",
}

function module.getCrosshairM16PositionOnScreen()
      local resolutionX, resolutionY = getScreenResolution()
      local onScreenX = resolutionX * 0.5299999714
      local onScreenY = resolutionY * 0.4

      return onScreenX, onScreenY
end

local function convertCartesianCoordinatesToSpherical(point)
      local camera = vector3D(getActiveCameraCoordinates())
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

local function getCrosshairRotation()
      local cameraMode = tonumber(SAMemory.camera.aCams[0].nMode)

      if CENTERED_CROSSHAIR_AIMING_MODES[cameraMode] then
            return getCameraRotation()
      end

      local crosshairOnScreenX, crosshairOnScreenY = getCrosshairM16PositionOnScreen()
      local crosshair = vector3D(convertScreenCoordsToWorld3D(crosshairOnScreenX, crosshairOnScreenY, 5))

      return convertCartesianCoordinatesToSpherical(crosshair)
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

function module.moveCrosshairTowardsPoint(point, k)
      local pointPhi, pointTheta = convertCartesianCoordinatesToSpherical(point)
      local cameraPhi, cameraTheta = getCameraRotation()
      local crosshairPhi, crosshairTheta = getCrosshairRotation()

      cameraPhi = cameraPhi + k * (pointPhi - crosshairPhi)
      cameraTheta = cameraTheta + k * (pointTheta - crosshairTheta)

      setCameraRotation(cameraPhi, cameraTheta)
end

return module