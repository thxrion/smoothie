local ffi = require("ffi")

local bones = {}

local bonesIds = {
      SPINE = 3,
      NECK = 5,
      RIGHT_EYE = 7,
      LEFT_EYE = 8,
      RIGHT_SHOULDER = 22,
      LEFT_ELBOW = 33,
      RIGHT_BREAST = 301,
      LEFT_BREAST = 302,
      BELLY = 201,
      LEFT_KNEE = 42,
      RIGHT_KNEE = 52,
}

local getBonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280)

function bones.getBonePosition3D(ped, boneId)
      local buffer = ffi.new("float[3]")
      local pedPointer = ffi.cast("void*", getCharPointer(ped))
      getBonePosition(pedPointer, buffer, boneId, true)

      return vector3D(buffer[0], buffer[1], buffer[2])
end

function bones.getHeadPosition3D(ped)
      local rightEye = getBonePosition3d(ped, bonesIds.RIGHT_EYE)
      local leftEye = getBonePosition3d(ped, boneIDs.LEFT_EYE)

      return (leftEye + rightEye) * 0.5
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

function bones.isInLineOfSight(ped, bonedId)
      local camera = vector3D(getActiveCameraCoordinates())
      local bone = bones.getBonePosition3D(ped, bonedId)

      return processLineOfSight(
            camera.x, camera.y, camera.z,
            bone.x, bone.y, bone.z,
            options.checkIfSolid,
            options.vehicles,
            options.pedestrians,
            options.particles,
            options.seeThroughObjects,
            options.ignoreSomeObjects,
            options.objectsYouCanShootThrough
      )
end

return bones
