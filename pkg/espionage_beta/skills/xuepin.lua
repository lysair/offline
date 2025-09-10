local xuepin = fk.CreateSkill {
  name = "xuepin",
}

Fk:loadTranslationTable{
  ["xuepin"] = "血拼",
  [":xuepin"] = "出牌阶段限一次，你可以失去1点体力，弃置你攻击范围内一名角色至多两张牌。若弃置的两张牌类别相同，你回复1点体力。",

  ["#xuepin"] = "血拼：失去1点体力弃置攻击范围内一名角色两张牌，若类别相同你回复1点体力",
}

xuepin:addEffect("active", {
  anim_type = "control",
  prompt = "#xuepin",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(xuepin.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and player:inMyAttackRange(to_select) and not to_select:isNude()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:loseHp(player, 1, xuepin.name)
    if player.dead or target:isNude() then return end
    local cards = room:askToChooseCards(player, {
      min = 1,
      max = 2,
      flag = "he",
      skill_name = xuepin.name,
      target = target,
    })
    room:throwCard(cards, xuepin.name, target, player)
    if player.dead then return end
    if #cards == 2 and Fk:getCardById(cards[1]).type == Fk:getCardById(cards[2]).type then
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = xuepin.name,
      }
    end
  end,
})

return xuepin
