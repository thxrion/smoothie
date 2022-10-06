script_author("THERION")

local WEAPON_DATA = nil
local PLAYER_IN_SCOPE_CAMERA_MODES = {
  [7] = "MODE_SNIPER",
  [8] = "MODE_ROCKETLAUNCHER",
  [46] = "MODE_CAMERA",
  [51] = "MODE_ROCKETLAUNCHER_HS",
}

local settings = {
  radius = {
    HANDGUN = 30,
    SUBMACHINE = 15,
    SHOTGUN = 30,
    RIFLE = 15,
  }
  chance = 35,

  color_filter = false,
  wall_filter = true,
  distance_filter = true,

  driver_filter = false,
  focus_drivers = true,

  draw_radius = true,
}

local ffi = require("ffi")
local memory = require("memory")
local samp_events = require("samp.events")

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

local function foreach_valid_enemy_in_stream(callback)
  local all_chars = getAllChars()

  for _, potential_target in ipairs(all_chars) do
    if potential_target == PLAYER_PED then
      goto next
    end

    if isCharDead(potential_target) then
      goto next
    end
    
    local is_not_npc, _ = sampGetPlayerIdByCharHandle(potential_target)
    if not is_not_npc then
      goto next
    end
    
    if callback(potential_target) then
      return
    end

    ::next::
  end
end

/*
if color_filter && sampGetPlayerColor(potential_target_id) == sampGetPlayerColor(local_player_id) then
  goto next
end

local is_los_clear = isLineOfSightClear(
  getActiveCameraCoordinates(),
  x, y, z,
  wall_filter,
  wall_filter,
  false,
  wall_filter,
  false
)

if not is_los_clear then
  goto next
end
*/

local function on_before_init()
  math.randomseed(os.time())
end

local function on_init()
  sampRegisterChatCommand('enemies', function()
    foreach_valid_enemy_in_stream(function(enemy)
      const _, id = sampGetPlayerIdByCharHandle(enemy)
      print(id)
      return false
    end)
  end)
end

local function on_every_frame()
  if not draw_radius then
    return
  end

  local crosshair_x, crosshair_y = get_crosshair_position_2d()
  renderDrawPolygon(crosshair_x, crosshair_y, settings.radius_handgun, settings.radius_handgun, 24, 0, 0x8000C000)
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


local function create_weapon_data_entry(type, range, damage)
  return { type = type, range = range, damage = damage }
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