local leiruo = fk.CreateSkill {
  name = "leiruo",
}

Fk:loadTranslationTable{
  ["leiruo"] = "羸弱",
  [":leiruo"] = "结束阶段，你可以获得一名其他角色装备区内的一张牌，然后其可以视为对你使用一张无距离限制的【杀】。",

  ["#leiruo-choose"] = "羸弱：你可以获得一名角色一张装备，其可以视为对你使用【杀】",
  ["#leiruo-slash"] = "羸弱：是否视为对 %src 使用【杀】？",
}

leiruo:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(leiruo.name) and player.phase == Player.Finish and
      table.find(player.room:getOtherPlayers(player, false), function (p)
        return #p:getCardIds("e") > 0
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return #p:getCardIds("e") > 0
    end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = leiruo.name,
      prompt = "#leiruo-choose",
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local card = room:askToChooseCard(player, {
      target = to,
      flag = "e",
      skill_name = leiruo.name,
    })
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, leiruo.name, nil, true, player)
    if player.dead or to.dead then return end
    if to:canUseTo(Fk:cloneCard("slash"), player, { bypass_distances = true, bypass_times = true }) and
      room:askToSkillInvoke(to, {
        skill_name = leiruo.name,
        prompt = "#leiruo-slash:"..player.id,
      }) then
      room:useVirtualCard("slash", nil, to, player, leiruo.name, true)
    end
  end,
})

return leiruo