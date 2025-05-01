local sheju = fk.CreateSkill {
  name = "sheju",
}

Fk:loadTranslationTable{
  ["sheju"] = "射驹",
  [":sheju"] = "当你使用【杀】结算后，你可以弃置其中一名目标角色一张牌，若不为坐骑牌，其本回合攻击范围+1，然后若其攻击范围内包含你，其可以"..
  "对你使用一张【杀】。",

  ["#sheju-invoke"] = "射驹：你可以弃置 %dest 一张牌，若不为坐骑，其攻击范围+1且可以对你使用【杀】",
  ["#sheju-choose"] = "射驹：你可以弃置其中一名角色一张牌，若不为坐骑，其攻击范围+1且可以对你使用【杀】",
  ["@sheju-turn"] = "射驹",
  ["#sheju-slash"] = "射驹：你可以对 %src 使用一张【杀】",
}

sheju:addEffect(fk.CardUseFinished, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(sheju.name) and data.card.trueName == "slash" and
      table.find(data.tos, function (p)
        return not p.dead and not p:isNude()
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(data.tos, function (p)
      return not p.dead and not p:isNude()
    end)
    if #targets == 1 then
      if room:askToSkillInvoke(player, {
        skill_name = sheju.name,
        prompt = "#sheju-invoke::"..targets[1].id,
      }) then
        event:setCostData(self, {tos = targets})
        return true
      end
    else
      local to = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 1,
        targets = targets,
        skill_name = sheju.name,
        prompt = "#sheju-choose",
        cancelable = true,
      })
      if #to > 0 then
        event:setCostData(self, {tos = to})
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local card = room:askToChooseCard(player, {
      target = to,
      flag = "he",
      skill_name = sheju.name,
    })
    local yes = not table.contains({Card.SubtypeOffensiveRide, Card.SubtypeDefensiveRide}, Fk:getCardById(card).sub_type)
    room:throwCard(card, sheju.name, to, player)
    if yes and not to.dead then
      room:addPlayerMark(to, "@sheju-turn", 1)
      if not player.dead and to:inMyAttackRange(player) then
        local use = room:askToUseCard(to, {
          skill_name = sheju.name,
          pattern = "slash",
          prompt = "#sheju-slash:"..player.id,
          extra_data = {
            exclusive_targets = {player.id},
            bypass_times = true,
          }
        })
        if use then
          use.extraUse = true
          room:useCard(use)
        end
      end
    end
  end,
})

return sheju
