local wuweic = fk.CreateSkill {
  name = "wuweic",
}

Fk:loadTranslationTable{
  ["wuweic"] = "无为",
  [":wuweic"] = "当你受到伤害后，你可以将一张装备牌置入一名角色的装备区内，然后弃置其X张牌（X为其因此增加的攻击范围）。",

  ["#wuweic-invoke"] = "无为：你可以将一张装备牌置入一名角色的装备区，然后弃置其增加攻击范围数的牌",
}

wuweic:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(wuweic.name) and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local success, dat = room:askToUseActiveSkill(player, {
      skill_name = "#wuweic_active",
      prompt = "#wuweic-invoke",
      cancelable = true,
    })
    if success and dat then
      event:setCostData(self, { cards = dat.cards, tos = dat.targets })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local n1 = to:getAttackRange()
    local id = event:getCostData(self).cards[1]
    room:moveCardIntoEquip(to, id, wuweic.name, false, player)
    local n2 = to:getAttackRange()
    if player.dead or to.dead or n2 <= n1 or to:isNude() then return end
    n1 = n2 - n1
    if to == player then
      room:askToDiscard(player, {
        min_num = n1,
        max_num = n1,
        include_equip = true,
        skill_name = wuweic.name,
        cancelable = false,
      })
    else
      local cards = room:askToChooseCards(player, {
        target = to,
        min = n1,
        max = n1,
        flag = "he",
        skill_name = wuweic.name,
      })
      room:throwCard(cards, wuweic.name, to, player)
    end
  end,
})

return wuweic