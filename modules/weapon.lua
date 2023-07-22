local weapon = {}

do
      weapon.FireArm = {
            COLT45 = 22,
            SILENCED = 23,
            DESERTEAGLE = 24,
            SHOTGUN = 25,
            SAWNOFFSHOTGUN = 26,
            COMBATSHOTGUN = 27,
            UZI = 28,
            MP5 = 29,
            AK47 = 30,
            M4 = 31,
            TEC9 = 32,
            RIFLE = 33,
            SNIPERRIFLE = 34,
            MINIGUN = 38,
      }

      weapon.Type = {
            HANDGUN = 1,
            SHOTGUN = 2,
            SUBMACHINE = 3,
            RIFLE = 4,
      }

      local WEAPON_TYPE_MAP = {
            [weapon.FireArm.COLT45] = weapon.Type.HANDGUN,
            [weapon.FireArm.SILENCED] = weapon.Type.HADNGUN,
            [weapon.FireArm.DESERTEAGLE] = weapon.Type.HANDGUN,
            [weapon.FireArm.SHOTGUN] = weapon.Type.SHOTGUN,
            [weapon.FireArm.SAWNOFFSHOTGUN] = weapon.Type.SHOTGUN,
            [weapon.FireArm.COMBATSHOTGUN] = weapon.Type.SHOTGUN,
            [weapon.FireArm.UZI] = weapon.Type.SUBMACHINE,
            [weapon.FireArm.MP5] = weapon.Type.SUBMACHINE,
            [weapon.FireArm.AK47] = weapon.Type.RIFLE,
            [weapon.FireArm.M4] = weapon.Type.RIFLE,
            [weapon.FireArm.TEC9] = weapon.Type.SUBMACHINE,
            [weapon.FireArm.RIFLE] = weapon.Type.RIFLE,
            [weapon.FireArm.SNIPERRIFLE] = weapon.Type.RIFLE,
            [weapon.FireArm.MINIGUN] = weapon.Type.RIFLE,
      }

      local WEAPON_RANGE_MAP = {
            [weapon.FireArm.COLT45] = 35.0,
            [weapon.FireArm.SILENCED] = 35.0,
            [weapon.FireArm.DESERTEAGLE] = 35.0,
            [weapon.FireArm.SHOTGUN] = 40.0,
            [weapon.FireArm.SAWNOFFSHOTGUN] = 35.0,
            [weapon.FireArm.COMBATSHOTGUN] = 40.0,
            [weapon.FireArm.UZI] = 35.0,
            [weapon.FireArm.MP5] = 45.0,
            [weapon.FireArm.AK47] = 70.0,
            [weapon.FireArm.M4] = 90.0,
            [weapon.FireArm.TEC9] = 35.0,
            [weapon.FireArm.RIFLE] = 95.0,
            [weapon.FireArm.SNIPERRIFLE] = 320.0,
            [weapon.FireArm.MINIGUN] = 75.0,
      }

      function weapon.getType()
            local weaponId = getCurrentCharWeapon(PLAYER_PED)
            return WEAPON_TYPE_MAP[weaponId]
      end

      function weapon.getRange()
            local weaponId = getCurrentCharWeapon(PLAYER_PED)
            return WEAPON_RANGE_MAP[weaponId]
      end

      function weapon.setSpread(percent)
            memory.setfloat(0x008D6114, percent / 20, 1)
      end

      function weapon.resetSpread()
            weapon.setSpread(100)
      end

end
