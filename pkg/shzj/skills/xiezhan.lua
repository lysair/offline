local xiezhan = fk.CreateSkill {
  name = "xiezhan",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["xiezhan"] = "协战",
  [":xiezhan"] = "锁定技，游戏开始时，你选择范疆或张达；出牌阶段开始时，你变更武将牌。",

  ["#xiezhan-choose"] = "协战：请选择变为范疆或张达",
}

xiezhan:addEffect(fk.GameStart, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(xiezhan.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local isDeputy = player.deputyGeneral == "fanjiang" or player.deputyGeneral == "zhangda"
    local result = room:askToChooseGeneral(player, {
      n = 1,
      generals = {"fanjiang", "zhangda"},
      no_convert = true,
    })
    if (isDeputy and player.deputyGeneral == result) or (not isDeputy and player.general == result) then return end
    room:changeHero(player, result, false, isDeputy, true, false, false)
  end,
})

xiezhan:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xiezhan.name) and player.phase == Player.Play
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player.general == "fanjiang" then
      room:changeHero(player, "zhangda", false, false, true, false, false)
    elseif player.general == "zhangda" then
      room:changeHero(player, "fanjiang", false, false, true, false, false)
    end
    if player.deputyGeneral == "fanjiang" then
      room:changeHero(player, "zhangda", false, true, true, false, false)
    elseif player.deputyGeneral == "zhangda" then
      room:changeHero(player, "fanjiang", false, true, true, false, false)
    end
  end,
})

return xiezhan
