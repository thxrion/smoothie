local memory = require("memory")
local weaponId = require("game.weapons")

local weapon = {}

weapon.aimable = {
      weaponId.COLT45,
      weaponId.SILENCED,
      weaponId.DESERTEAGLE,
      weaponId.SHOTGUN,
      weaponId.SAWNOFFSHOTGUN,
      weaponId.COMBATSHOTGUN,
      weaponId.UZI,
      weaponId.MP5,
      weaponId.AK47,
      weaponId.M4,
      weaponId.TEC9,
      weaponId.RIFLE,
      weaponId.SNIPERRIFLE,
      weaponId.MINIGUN,
}

weapon.types = {
      LIGHT = 1,
      HEAVY = 2,
}

weapon.range = {
      [weaponId.COLT45] = 35.0,
      [weaponId.SILENCED] = 35.0,
      [weaponId.DESERTEAGLE] = 35.0,
      [weaponId.SHOTGUN] = 40.0,
      [weaponId.SAWNOFFSHOTGUN] = 35.0,
      [weaponId.COMBATSHOTGUN] = 40.0,
      [weaponId.UZI] = 35.0,
      [weaponId.MP5] = 45.0,
      [weaponId.AK47] = 70.0,
      [weaponId.M4] = 90.0,
      [weaponId.TEC9] = 35.0,
      [weaponId.RIFLE] = 95.0,
      [weaponId.SNIPERRIFLE] = 320.0,
      [weaponId.MINIGUN] = 75.0,
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
