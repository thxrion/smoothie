script_author("THERION")

local BONES = nil
local WEAPON_DATA = nil
local PLAYER_IN_SCOPE_CAMERA_MODES = nil

local ffi = require("ffi")
local memory = require("memory")
local samp_events = require("samp.events")

local settings = nil

local compute_3d_person_mouse_target = ffi.cast("void (__thiscall*)(void*, float, float, float, float, float*, float*)", 0x514970)
local get_bone_position = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280)

local function get_camera_mode()
  return memory.getuint8(0xB6F1A8, false)
end

local function get_crosshair_position_2d()
  local camera_mode = get_camera_mode()

  if PLAYER_IN_SCOPE_CAMERA_MODES[camera_mode] then
    local resolution_x, resolution_y = getScreenResolution()
    return resolution_x / 2, resolution_y / 2
  end

  local out, tmp = ffi.new("float[3]"), ffi.new("float[3]")
  local the_camera = ffi.cast('void*', 0xB6F028)

  compute_3d_person_mouse_target(the_camera, 15.0, tmp[0], tmp[1], tmp[2], tmp, out)
  return convert3DCoordsToScreen(out[0], out[1], out[2])
end

local function get_bone_position_3d(ped, bone_id)
  local vec = ffi.new("float[3]")
  local ped_pointer = ffi.cast("void*", getCharPointer(ped))
  get_bone_position(ped_pointer, vec, bone_id, true)
  return vec[0], vec[1], vec[2]
end

local function foreach(array, callback)
  for k, v in ipairs(array) do
    local result = callback(v, k)
    if result then
      return result
    end
  end
end

local function foreach_potential_target(callback)
  local local_x, local_y, local_z = getCharCoordinates(PLAYER_PED)
  local _, local_player_id = sampGetPlayerIdByCharHandle(PLAYER_PED)

  local weapon_data = WEAPON_DATA[getCurrentCharWeapon(PLAYER_PED)]
  if not weapon_data then
    return
  end

  return foreach(getAllChars(), function(potential_target)
    if potential_target == PLAYER_PED then
      return
    end

    if isCharDead(potential_target) then
      return
    end

    local is_not_npc, potential_target_id = sampGetPlayerIdByCharHandle(potential_target)
    if not is_not_npc then
      return
    end
    if not isCharOnScreen(potential_target) then
      return
    end
    
    if settings.color_filter and sampGetPlayerColor(potential_target_id) ~= sampGetPlayerColor(local_player_id) then
      return
    end

    if settings.range_filter and getDistanceBetweenCoords3d(local_x, local_y, local_z, getCharCoordinates(potential_target)) > weapon_data.max_range then
      return
    end

    local result = callback(potential_target)
    if result then
      return result
    end
  end)
end

local function foreach_valid_driver(callback)
  local crosshair_x, crosshair_y = get_crosshair_position_2d()
  local camera_x, camera_y, camera_z = getActiveCameraCoordinates()
  local weapon_data = WEAPON_DATA[getCurrentCharWeapon(PLAYER_PED)]
  if not weapon_data then
    return
  end

  return foreach_potential_target(function(potential_target)
    if not isCharInAnyCar(potential_target) then
      return
    end

    local right_eye_x, right_eye_y, right_eye_z = get_bone_position_3d(ped, 6)
    local left_eye_x, left_eye_y, left_eye_z = get_bone_position_3d(ped, 7)
  
    local head_x = (right_eye_x + left_eye_x) / 2
    local head_y = (right_eye_y + left_eye_y) / 2
    local head_z = (right_eye_z + left_eye_z) / 2

    if not isLineOfSightClear(camera_x, camera_y, camera_z, head_x, head_y, head_z, settings.wall_filter, false, false, settings.wall_filter, false) then
      return
    end

    local head_on_screen_x, head_on_screen_y = convert3DCoordsToScreen(head_x, head_y, head_z)
    if getDistanceBetweenCoords2d(head_on_screen_x, head_on_screen_y, crosshair_x, crosshair_y) > settings.radius[weapon_data.type] then
      return
    end

    local result = callback(potential_target)
    if result then
      return result
    end
  end)
end

local function foreach_valid_pedestrian(callback)
  local crosshair_x, crosshair_y = get_crosshair_position_2d()
  local camera_x, camera_y, camera_z = getActiveCameraCoordinates()
  local weapon_data = WEAPON_DATA[getCurrentCharWeapon(PLAYER_PED)]
  if not weapon_data then
    return
  end

  return foreach_potential_target(function(potential_target)
    if not isCharInAnyCar(potential_target) then
      return
    end

    local bone = foreach(settings.bones, function(bone)
      local bone_x, bone_y, bone_z = get_bone_position_3d(potential_target, bone)
      if not isLineOfSightClear(camera_x, camera_y, camera_z, bone_x, bone_y, bone_z, settings.wall_filter, settings.wall_filter, false, settings.wall_filter, false) then
        return
      end
      
      local bone_on_screen_x, bone_on_screen_y = convert3DCoordsToScreen(head_x, head_y, head_z)
      if getDistanceBetweenCoords2d(bone_on_screen_x, bone_on_screen_y, crosshair_x, crosshair_y) > settings.radius[weapon_data.type] then
        return
      end

      return bone
    end)

    if bone then
      return potential_target
    end
  end)
end

local function on_before_init()
  math.randomseed(os.time())
end

local function on_init()
end

local function render_debug_sphere(x, y, z, radius)
  local quarter_of_pi = math.pi / 4
  local angles = {}
  for i = 0, 7 do
    table.insert(angles, quarter_of_pi * i)
  end

  for _, horizontal_angle in ipairs(angles) do
    for _, vertical_angle in ipairs(angles) do
      local offset_x = radius * math.sin(vertical_angle) * math.cos(horizontal_angle)
      local offset_y = radius * math.sin(vertical_angle) * math.sin(horizontal_angle)
      local offset_z = radius * math.cos(vertical_angle)
    
      local screen_x, screen_y = convert3DCoordsToScreen(x + offset_x, y + offset_y, z + offset_z)
      renderDrawPolygon(screen_x, screen_y, 4, 4, 4, 0, 0x50FFFFFF)
    end
  end
end

local function render_debug_radius()
  local crosshair_x, crosshair_y = get_crosshair_position_2d()
  local weapon_data = WEAPON_DATA[getCurrentCharWeapon(PLAYER_PED)]
  if not weapon_data then
    return
  end

  local diameter = settings.radius[weapon_data.type] * 2
  renderDrawPolygon(crosshair_x, crosshair_y, diameter, diameter, 30, 0, 0x50FFFFFF)
end

local function on_every_frame()
  foreach_potential_target(function(potential_target)
    do
      local bone_x, bone_y, bone_z = get_bone_position_3d(potential_target, 3)
      render_debug_sphere(bone_x, bone_y, bone_z, 0.04)
    end
  end)
  
  if not settings.draw_radius then
    return
  end

  render_debug_radius()
end

local function on_send_bullet_sync()

end

function main()
  on_before_init()
  repeat wait(0) until isSampAvailable()
  on_init()
  while true do
    wait(0)
    on_every_frame()
  end
end

function samp_events.onSendBulletSync()
  on_send_bullet_sync()
end

settings = {
  radius = {
    HANDGUN = 120,
    SUBMACHINE = 15,
    SHOTGUN = 30,
    RIFLE = 15,
  },
  bones = {
    3, 5, 7, 8, 201, 42, 52,
  },
  chance = 35,
  color_filter = false,
  wall_filter = true,
  range_filter = true,
  driver_filter = false,
  focus_drivers = true,
  draw_radius = true,
}

BONES = {
  [3] = "Spine",
  [5] = "Neck",
  [7] = "Right eye",
  [8] = "Left eye",
  [22] = "Right shoulder",
  [32] = "Left shoulder",
  [23] = "Right elbow",
  [33] = "Left elbow",
  [301] = "Right tit",
  [302] = "Left tit",
  [201] = "Belly",
  [42] = "Left knee",
  [52] = "Right knee",
}

PLAYER_IN_SCOPE_CAMERA_MODES = {
  [7] = "MODE_SNIPER",
  [8] = "MODE_ROCKETLAUNCHER",
  [46] = "MODE_CAMERA",
  [51] = "MODE_ROCKETLAUNCHER_HS",
}

local function create_weapon_data_entry(type, max_range, damage)
  return { type = type, max_range = max_range, damage = damage }
end
WEAPON_DATA = {
  [22] = create_weapon_data_entry("HANDGUN", 35.0, 8.25),
  [23] = create_weapon_data_entry("HADNGUN", 35.0, 13.2),
  [24] = create_weapon_data_entry("HANDGUN", 35.0, 46.200000762939),
  [25] = create_weapon_data_entry("SHOTGUN", 40.0, 30),
  [26] = create_weapon_data_entry("SHOTGUN", 35.0, 30),
  [27] = create_weapon_data_entry("SHOTGUN", 40.0, 30),
  [28] = create_weapon_data_entry("SUBMACHINE", 35.0, 6.6),
  [29] = create_weapon_data_entry("SUBMACHINE", 45.0, 8.25),
  [30] = create_weapon_data_entry("RIFLE", 70.0, 9.900024),
  [31] = create_weapon_data_entry("RIFLE", 90.0, 9.9000005722046),
  [32] = create_weapon_data_entry("SUBMACHINE", 35.0, 6.6),
  [33] = create_weapon_data_entry("RIFLE", 95.0, 24.750001907349),
  [34] = create_weapon_data_entry("RIFLE", 320.0, 41),
  [38] = create_weapon_data_entry("RIFLE", 75.0, 46.2),
}