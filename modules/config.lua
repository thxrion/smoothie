local config = {
      toggleConfigMenuKey = 0x5A,
      isWindowOpen = imgui.new.bool(false),

      isEnabled = imgui.new.bool(true),
      doesAimingRequireFireButtonPress = imgui.new.bool(false),
      areDriversPrioritized = imgui.new.bool(true),
      shouldPedBeInLineOfSight = imgui.new.bool(true),
      shouldPedBeInRange = imgui.new.bool(false),
      shouldPedHaveOtherColor = imgui.new.bool(true),

      weaponTypeSpecific = {
            [weapon.Type.HANDGUN] = {
                  radius = imgui.new.int(120),
                  smoothness = imgui.new.float(1),
                  spread = imgui.new.float(100),
            },
            [weapon.Type.SHOTGUN] = {
                  radius = imgui.new.int(100),
                  smoothness = imgui.new.float(1),
                  spread = imgui.new.float(100),
            },
            [weapon.Type.SUBMACHINE] = {
                  radius = imgui.new.int(60),
                  smoothness = imgui.new.float(1),
                  spread = imgui.new.float(100),
            },
            [weapon.Type.RIFLE] = {
                  radius = imgui.new.int(20),
                  smoothness = imgui.new.float(1),
                  spread = imgui.new.float(100),
            },
      },

      bones = {
            bone.Type.SPINE,
            bone.Type.NECK,
            bone.Type.RIGHT_EYE,
            bone.Type.LEFT_EYE,
            bone.Type.RIGHT_SHOULDER,
            bone.Type.LEFT_ELBOW,
            bone.Type.RIGHT_BREAST,
            bone.Type.LEFT_BREAST,
            bone.Type.BELLY,
            bone.Type.LEFT_KNEE,
            bone.Type.RIGHT_KNEE,
      },
}

function config.getWeaponConfig()
      local weaponType = weapon.getType()
      return config.weaponTypeSpecific[weaponType]
end

return config