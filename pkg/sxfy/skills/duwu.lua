local duwu = fk.CreateSkill{
  name = "sxfy__duwu",
}

Fk:loadTranslationTable{
  ["sxfy__duwu"] = "黩武",
  [":sxfy__duwu"] = "出牌阶段限一次，你可以弃置所有手牌，对攻击范围内的一名角色造成1点伤害。",

  ["#sxfy__duwu"] = "黩武：弃置所有手牌，对一名角色造成1点伤害",
}

duwu:addEffect("active", {
  anim_type = "offensive",
  prompt = "#sxfy__duwu",
  card_num = 0,
  target_num = 1,
  can_use = function (self, player)
    return player:usedSkillTimes(duwu.name, Player.HistoryPhase) == 0 and
      table.find(player:getCardIds("h"), function (id)
        return not player:prohibitDiscard(id)
      end)
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and player:inMyAttackRange(to_select)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    player:throwAllCards("h", duwu.name)
    if not target.dead then
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = duwu.name,
      }
    end
  end,
})

return duwu
