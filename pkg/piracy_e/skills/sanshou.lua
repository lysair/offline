local sanshou = fk.CreateSkill {
  name = "ofl__sanshou",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl__sanshou"] = "三首",
  [":ofl__sanshou"] = "锁定技，你的准备阶段和结束阶段改为出牌阶段，并在此阶段将武将牌改为张宝或张梁。此阶段结束后把武将牌替换回张角。",

  ["#ofl__sanshou-choose"] = "三首：选择此阶段要变为的武将",
}

sanshou:addEffect(fk.EventPhaseChanging, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(sanshou.name) and table.contains({Player.Start, Player.Finish}, data.phase)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data.phase = Player.Play
    local isDeputy = true
    if player.general == "ofl__godzhangjiao" then
      isDeputy = false
    end
    room:setPlayerMark(player, "ofl__sanshou-phase", isDeputy and 2 or 1)
    local result = room:askToChooseGeneral(player, {
      n = 1,
      generals = {"ofl__godzhangbao", "ofl__godzhangliang"},
      no_convert = true,
    })
    room:changeHero(player, result, false, isDeputy, true, false, false)
  end,
})

sanshou:addEffect(fk.EventPhaseEnd, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("ofl__sanshou-phase") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:changeHero(player, "ofl__godzhangjiao", false, player:getMark("ofl__sanshou-phase") == 2, true, false, false)
  end,
})

return sanshou
