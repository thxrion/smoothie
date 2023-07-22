local bone = {}

do
      local getBonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280)

      bone.Type = {
            RIGHT_WRIST = 24,
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

      function bone.getBonePosition3D(ped, boneId)
            local buffer = ffi.new("float[3]")
            local pedPointer = ffi.cast("void*", getCharPointer(ped))
            getBonePosition(pedPointer, buffer, boneId, true)

            return vector3D(buffer[0], buffer[1], buffer[2])
      end

      function bone.getHeadPosition3D(ped)
            local rightEye = bone.getBonePosition3D(ped, bone.Type.RIGHT_EYE)
            local leftEye = bone.getBonePosition3D(ped, bone.Type.LEFT_EYE)

            return (leftEye + rightEye) * 0.5
      end

end
