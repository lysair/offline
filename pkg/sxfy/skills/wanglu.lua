local wanglu = fk.CreateSkill {
  name = "sxfy__wanglu",
}

Fk:loadTranslationTable{
  ["sxfy__wanglu"] = "望橹",
  [":sxfy__wanglu"] = "出牌阶段限一次，你可以弃置场上一张装备牌，若为武器牌，失去此牌的角色摸X张牌（X为此武器攻击范围）。",

  ["#sxfy__wanglu"] = "望橹：弃置一名角色一张装备，若为武器其摸攻击范围张牌",
}

wanglu:addEffect("active", {
  anim_type = "control",
  prompt = "#sxfy__wanglu",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(wanglu.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and #to_select:getCardIds("e") > 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local id = room:askToChooseCard(player, {
      target = target,
      flag = "e",
      skill_name = wanglu.name,
    })
    local n = 0
    if Fk:getCardById(id).sub_type == Card.SubtypeWeapon then
      n = Fk:getCardById(id).attack_range
    end
    room:throwCard(id, wanglu.name, target, player)
    if target.dead or n == 0 then return end
    target:drawCards(n, wanglu.name)
  end,
})

return wanglu
