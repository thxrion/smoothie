local WEAPON_TYPE_NAMES = {
      [weapon.Type.HANDGUN] = "Handgun",
      [weapon.Type.SHOTGUN] = "Shotgun",
      [weapon.Type.SUBMACHINE] = "SMG",
      [weapon.Type.RIFLE] = "Rifle",
}

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

local function getTheme()
      imgui.SwitchContext()

      local style = imgui.GetStyle()
      style.WindowPadding = imgui.ImVec2(5, 5)
      style.FramePadding = imgui.ImVec2(5, 5)
      style.ItemSpacing = imgui.ImVec2(5, 5)
      style.ItemInnerSpacing = imgui.ImVec2(2, 2)
      style.TouchExtraPadding = imgui.ImVec2(0, 0)
      style.IndentSpacing = 0
      style.ScrollbarSize = 10
      style.GrabMinSize = 10

      style.WindowBorderSize = 1
      style.ChildBorderSize = 1
      style.PopupBorderSize = 1
      style.FrameBorderSize = 1
      style.TabBorderSize = 1

      style.WindowRounding = 5
      style.ChildRounding = 5
      style.FrameRounding = 5
      style.PopupRounding = 5
      style.ScrollbarRounding = 5
      style.GrabRounding = 5
      style.TabRounding = 5

      style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
      style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
      style.SelectableTextAlign = imgui.ImVec2(0.5, 0.5)

      style.Colors[imgui.Col.Text] = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
      style.Colors[imgui.Col.TextDisabled] = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
      style.Colors[imgui.Col.WindowBg] = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
      style.Colors[imgui.Col.ChildBg] = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
      style.Colors[imgui.Col.PopupBg] = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
      style.Colors[imgui.Col.Border] = imgui.ImVec4(0.25, 0.25, 0.26, 0.54)
      style.Colors[imgui.Col.BorderShadow] = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
      style.Colors[imgui.Col.FrameBg] = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
      style.Colors[imgui.Col.FrameBgHovered] = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
      style.Colors[imgui.Col.FrameBgActive] = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
      style.Colors[imgui.Col.TitleBg] = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
      style.Colors[imgui.Col.TitleBgActive] = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
      style.Colors[imgui.Col.TitleBgCollapsed] = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
      style.Colors[imgui.Col.MenuBarBg] = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
      style.Colors[imgui.Col.ScrollbarBg] = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
      style.Colors[imgui.Col.ScrollbarGrab] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
      style.Colors[imgui.Col.ScrollbarGrabHovered] = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
      style.Colors[imgui.Col.ScrollbarGrabActive] = imgui.ImVec4(0.51, 0.51, 0.51, 1.00)
      style.Colors[imgui.Col.CheckMark] = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
      style.Colors[imgui.Col.SliderGrab] = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
      style.Colors[imgui.Col.SliderGrabActive] = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
      style.Colors[imgui.Col.Button] = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
      style.Colors[imgui.Col.ButtonHovered] = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
      style.Colors[imgui.Col.ButtonActive] = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
      style.Colors[imgui.Col.Header] = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
      style.Colors[imgui.Col.HeaderHovered] = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
      style.Colors[imgui.Col.HeaderActive] = imgui.ImVec4(0.47, 0.47, 0.47, 1.00)
      style.Colors[imgui.Col.Separator] = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
      style.Colors[imgui.Col.SeparatorHovered] = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
      style.Colors[imgui.Col.SeparatorActive] = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
      style.Colors[imgui.Col.ResizeGrip] = imgui.ImVec4(1.00, 1.00, 1.00, 0.25)
      style.Colors[imgui.Col.ResizeGripHovered] = imgui.ImVec4(1.00, 1.00, 1.00, 0.67)
      style.Colors[imgui.Col.ResizeGripActive] = imgui.ImVec4(1.00, 1.00, 1.00, 0.95)
      style.Colors[imgui.Col.Tab] = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
      style.Colors[imgui.Col.TabHovered] = imgui.ImVec4(0.28, 0.28, 0.28, 1.00)
      style.Colors[imgui.Col.TabActive] = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
      style.Colors[imgui.Col.TabUnfocused] = imgui.ImVec4(0.07, 0.10, 0.15, 0.97)
      style.Colors[imgui.Col.TabUnfocusedActive] = imgui.ImVec4(0.14, 0.26, 0.42, 1.00)
      style.Colors[imgui.Col.PlotLines] = imgui.ImVec4(0.61, 0.61, 0.61, 1.00)
      style.Colors[imgui.Col.PlotLinesHovered] = imgui.ImVec4(1.00, 0.43, 0.35, 1.00)
      style.Colors[imgui.Col.PlotHistogram] = imgui.ImVec4(0.90, 0.70, 0.00, 1.00)
      style.Colors[imgui.Col.PlotHistogramHovered] = imgui.ImVec4(1.00, 0.60, 0.00, 1.00)
      style.Colors[imgui.Col.TextSelectedBg] = imgui.ImVec4(1.00, 0.00, 0.00, 0.35)
      style.Colors[imgui.Col.DragDropTarget] = imgui.ImVec4(1.00, 1.00, 0.00, 0.90)
      style.Colors[imgui.Col.NavHighlight] = imgui.ImVec4(0.26, 0.59, 0.98, 1.00)
      style.Colors[imgui.Col.NavWindowingHighlight] = imgui.ImVec4(1.00, 1.00, 1.00, 0.70)
      style.Colors[imgui.Col.NavWindowingDimBg] = imgui.ImVec4(0.80, 0.80, 0.80, 0.20)
      style.Colors[imgui.Col.ModalWindowDimBg] = imgui.ImVec4(0.00, 0.00, 0.00, 0.70)
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

function initConfigWindow()
      imgui.OnInitialize(getTheme)
      imgui.OnFrame(getConfigWindowState, onDrawConfigWindow)
      addEventHandler("onWindowMessage", onWindowMessage)
end