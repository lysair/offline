local taiguan = fk.CreateSkill {
  name = "taiguan",
}

Fk:loadTranslationTable{
  ["taiguan"] = "抬棺",
  [":taiguan"] = "出牌阶段限X次，你可以弃置一张牌并令攻击范围内的一名其他角色弃置一张牌，若其弃置的不为【杀】且你的体力值不大于其，"..
  "你视为对其使用一张【决斗】（X为你已损失体力值，至少为1）。",

  ["#taiguan"] = "抬棺：弃置一张牌，令一名角色弃一张牌",
  ["#taiguan-discard"] = "抬棺：你需弃置一张牌，若不为【杀】且你体力值不小于 %src，视为其对你使用【决斗】",
}

taiguan:addEffect("active", {
  anim_type = "offensive",
  prompt = "#taiguan",
  times = function(self, player)
    return player.phase == Player.Play and
      math.max(player:getLostHp(), 1) - player:usedSkillTimes(taiguan.name, Player.HistoryPhase) or -1
  end,
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(taiguan.name, Player.HistoryPhase) < math.max(player:getLostHp(), 1)
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and not player:prohibitDiscard(to_select)
  end,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and not to_select:isNude() and player:inMyAttackRange(to_select)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:throwCard(effect.cards, taiguan.name, player, player)
    if target.dead then return end
    local card = room:askToDiscard(target, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = taiguan.name,
      prompt = "#taiguan-discard:"..player.id,
      cancelable = false,
      skip = true,
    })
    if #card > 0 then
      card = Fk:getCardById(card[1])
      room:throwCard(card, taiguan.name, target, target)
      if card.trueName ~= "slash" and target.hp >= player.hp and
        not player.dead and not target.dead then
        room:useVirtualCard("duel", nil, player, target, taiguan.name)
      end
    end
  end,
})

return taiguan
