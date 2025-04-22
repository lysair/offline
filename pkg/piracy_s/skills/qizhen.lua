local qizhen = fk.CreateSkill {
  name = "ofl__qizhen",
}

Fk:loadTranslationTable{
  ["ofl__qizhen"] = "骑阵",
  [":ofl__qizhen"] = "当你使用【杀】结算后，若此【杀】造成伤害，你摸造成伤害值的牌；若未造成伤害，你弃置每名目标角色装备区的一张牌。",

  ["#ofl__qizhen-discard"] = "骑阵：弃置 %dest 装备区一张牌",
}

qizhen:addEffect(fk.CardUseFinished, {
  global = false,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(qizhen.name) and data.card.trueName == "slash" then
      if data.damageDealt then
        return true
      else
        return table.find(data.tos, function (p)
          return not p.dead and #p:getCardIds("e") > 0
        end)
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(qizhen.name)
    if data.damageDealt then
      room:notifySkillInvoked(player, qizhen.name, "drawcard")
      local n = 0
      for _, num in pairs(data.damageDealt) do
        n = num + n
      end
      player:drawCards(n, qizhen.name)
    else
      room:notifySkillInvoked(player, qizhen.name, "control")
      local targets = table.filter(data.tos, function (p)
        return not p.dead and #p:getCardIds("e") > 0
      end)
      room:doIndicate(player, targets)
      room:sortByAction(targets)
      for _, p in ipairs(targets) do
        if player.dead then return end
        if not p.dead and #p:getCardIds("e") > 0 then
          local card = p:getCardIds("e")[1]
          if #p:getCardIds("e") > 1 then
            card = room:askToChooseCard(player, {
              target = p,
              flag = "e",
              skill_name = qizhen.name,
              prompt = "#ofl__qizhen-discard::" .. p.id,
            })
          end
          room:throwCard(card, qizhen.name, p, player)
        end
      end
    end
  end,
})

return qizhen
