local collision = {}

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

collision.Entity = {
      NOTHING = 0,
      BUILDING = 1,
      VEHICLE = 2,
      PED = 3,
      OBJECT = 4,
      DUMMY = 5,
      NOTINPOOLS = 6,
}

function collision.processLine(origin, target, options)
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

function collision.isDriverInLineOfSight(driver)
      -- as in CTaskSimpleUseGun::FireGun
      local origin = bone.getBonePosition3D(PLAYER_PED, bone.Type.RIGHT_WRIST)
      local target = bone.getHeadPosition3D(driver)

      local hasReachedTarget, collisionData = collision.processLine(origin, target)

      if not hasReachedTarget then
            return false
      end

      if collisionData.entityType == collision.Entity.PED then
            -- return getCharPointerHandle(collisionData.entity) == driver
            return true
      end

      if collisionData.entityType ~= collision.Entity.VEHICLE then
            return false
      end

      local vehicle = getVehiclePointerHandle(collisionData.entity)
      local driverOfVehicleInLineOfSight = getDriverOfCar(vehicle)

      if not doesCharExist(driverOfVehicleInLineOfSight) then
            return false
      end

      return driverOfVehicleInLineOfSight == driver
end

function collision.isPedBoneInLineOfSight(ped, boneId)
      -- as in CTaskSimpleUseGun::FireGun
      local origin = bone.getBonePosition3D(PLAYER_PED, bone.Type.RIGHT_WRIST)
      local target = bone.getBonePosition3D(ped, boneId)

      local hasReachedTarget, collisionData = collision.processLine(origin, target)

      if not hasReachedTarget then
            return false
      end

      if collisionData.entityType ~= collision.Entity.PED then
            return false
      end

      return getCharPointerHandle(collisionData.entity) == ped
end

return collision