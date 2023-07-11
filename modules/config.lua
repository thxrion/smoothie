local config = {}

do

local ffi = require("ffi")
local imgui = require("mimgui")
local windowsMessages = require("windows.message")

local WEAPON_TYPE_NAMES = {
      [weapon.Type.HANDGUN] = "Handgun",
      [weapon.Type.SHOTGUN] = "Shotgun",
      [weapon.Type.SUBMACHINE] = "SMG",
      [weapon.Type.RIFLE] = "Rifle",
}

config = {
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

local function onWindowMessage(message, wparam)
      if message ~= windowsMessages.WM_KEYDOWN and message ~= windowsMessages.WM_SYSKEYDOWN then
            return
      end

      if sampIsChatInputActive() or isSampfuncsConsoleActive() or sampIsDialogActive() then
            return
      end

      if wparam ~= config.toggleConfigMenuKey then
            return
      end

      config.isWindowOpen[0] = not config.isWindowOpen[0]
end

local function getConfigWindowState()
      return config.isWindowOpen[0]
end

local function onDrawConfigWindow()
      imgui.SetNextWindowSize(imgui.ImVec2(320, 0))
      imgui.Begin("Configuration", config.isWindowOpen, imgui.WindowFlags.AlwaysAutoResize)

      imgui.Checkbox("Enabled", config.isEnabled)
      imgui.Checkbox("only when LMB is pressed", config.doesAimingRequireFireButtonPress)

      for weaponType, name in pairs(WEAPON_TYPE_NAMES) do
            if imgui.CollapsingHeader(name) then
                  local weaponConfig = config.weaponTypeSpecific[weaponType]

                  if imgui.InputInt("Radius##" .. weaponType, weaponConfig.radius) then
                        weaponConfig.radius[0] = clamp(weaponConfig.radius[0], 0, 1000)
                  end
                  if imgui.InputFloat("Smoothness##" .. weaponType, weaponConfig.smoothness) then
                        weaponConfig.smoothness[0] = clamp(weaponConfig.smoothness[0], 1, 20)
                  end

                  imgui.SliderFloat("Spread %##" .. weaponType, weaponConfig.spread, 0, 100)
            end
      end

      imgui.Checkbox("Prioritize drivers", config.areDriversPrioritized)
      imgui.Checkbox("Exclude targets not in line of sight", config.shouldPedBeInLineOfSight)
      imgui.Checkbox("Exclude targets not in range of weapon", config.shouldPedBeInRange)
      imgui.Checkbox("Exclude targets of same color", config.shouldPedHaveOtherColor)

      imgui.End()
end

function config.initWindow()
      addEventHandler("onWindowMessage", onWindowMessage)
      imgui.OnFrame(getConfigWindowState, onDrawConfigWindow)
end

end
