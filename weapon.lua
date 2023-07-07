local memory = require("memory")
local weaponIds = require("game.weapons")

local weapon = {}

weapon.aimable = {
      weaponIds.COLT45,
      weaponIds.SILENCED,
      weaponIds.DESERTEAGLE,
      weaponIds.SHOTGUN,
      weaponIds.SAWNOFFSHOTGUN,
      weaponIds.COMBATSHOTGUN,
      weaponIds.UZI,
      weaponIds.MP5,
      weaponIds.AK47,
      weaponIds.M4,
      weaponIds.TEC9,
      weaponIds.RIFLE,
      weaponIds.SNIPERRIFLE,
      weaponIds.MINIGUN,
}

weapon.types = {
      LIGHT = 1,
      HEAVY = 2,
}

weapon.range = {
      [weaponIds.COLT45] = 35.0,
      [weaponIds.SILENCED] = 35.0,
      [weaponIds.DESERTEAGLE] = 35.0,
      [weaponIds.SHOTGUN] = 40.0,
      [weaponIds.SAWNOFFSHOTGUN] = 35.0,
      [weaponIds.COMBATSHOTGUN] = 40.0,
      [weaponIds.UZI] = 35.0,
      [weaponIds.MP5] = 45.0,
      [weaponIds.AK47] = 70.0,
      [weaponIds.M4] = 90.0,
      [weaponIds.TEC9] = 35.0,
      [weaponIds.RIFLE] = 95.0,
      [weaponIds.SNIPERRIFLE] = 320.0,
      [weaponIds.MINIGUN] = 75.0,
}



function weapon.isAimable()
      local weaponId = getCurrentCharWeapon(PLAYER_PED)
      return arrayFind(weapon.aimable, weaponId)
end

function weapon.getType()
      local weaponId = getCurrentCharWeapon(PLAYER_PED)

      if weaponId <= 24 then
            return weapon.types.LIGHT
      end
      
      return weapon.types.HEAVY
end

function weapon.getRange()
      local weaponId = getCurrentCharWeapon(PLAYER_PED)
      return weapon.range[weaponId]
end

function weapon.setSpread(percent)
      memory.setfloat(0x008D6114, percent / 20, 1)
end
      
function weapon.resetSpread()
      weapon.setSpread(100)
end

return weapon