local jiaochong = fk.CreateSkill {
  name = "sxfy__jiaochong",
}

Fk:loadTranslationTable{
  ["sxfy__jiaochong"] = "椒宠",
  [":sxfy__jiaochong"] = "男性角色的结束阶段，你可以发动一次〖诬诽〗。",
}

jiaochong:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(jiaochong.name) and target.phase == Player.Finish and target:isMale() and
      table.find(player.room.alive_players, function (p)
        return p:isFemale() and not p:isKongcheng()
      end)
  end,
  on_trigger = function(self, event, target, player, data)
    Fk.skills["sxfy__wufei"]:doCost(event, target, player, data)
  end,
})

return jiaochong
