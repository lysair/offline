local yinbing = fk.CreateSkill {
  name = "qshm__yinbing",
}

Fk:loadTranslationTable{
  ["qshm__yinbing"] = "引兵",
  [":qshm__yinbing"] = "结束阶段，你可以将任意名攻击范围内包含你的角色各一张手牌置于你的武将牌上。当你受到【杀】或【决斗】造成的伤害后，"..
  "伤害来源可以获得一张“引兵”牌。",

  ["$yinbing"] = "引兵",
  ["#qshm__yinbing-choose"] = "引兵：你可以将任意任意名角色各一张手牌置为“引兵”牌",
  ["#qshm__yinbing-prey"] = "引兵：你可以获得 %src 的一张“引兵”牌",
}

yinbing:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  derived_piles = "$yinbing",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yinbing.name) and player.phase == Player.Finish and
      table.find(player.room:getOtherPlayers(player, false), function (p)
        return p:inMyAttackRange(player) and not p:isKongcheng()
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return p:inMyAttackRange(player) and not p:isKongcheng()
    end)
    local tos = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 10,
      targets = targets,
      skill_name = yinbing.name,
      prompt = "#qshm__yinbing-choose",
      cancelable = true,
    })
    if #tos > 0 then
      room:sortByAction(tos)
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(event:getCostData(self).tos) do
      if not player:hasSkill(yinbing.name, true) then return end
      if not p:isKongcheng() then
        local card = room:askToChooseCard(player, {
          target = p,
          flag = "h",
          skill_name = yinbing.name,
        })
        player:addToPile("$yinbing", card, false, yinbing.name)
      end
    end
  end,
})

yinbing:addEffect(fk.Damaged, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yinbing.name) and #player:getPile("$yinbing") > 0 and
      data.card and (data.card.trueName == "slash" or data.card.name == "duel") and
      data.from and not data.from.dead
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(data.from, {
      skill_name = yinbing.name,
      prompt = "#qshm__yinbing-prey:"..player.id,
    }) then
      room:doIndicate(data.from, {player})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = room:askToChooseCard(data.from, {
      target = target,
      flag = { card_data = {{ yinbing.name, player:getPile("$yinbing") }} },
      skill_name = yinbing.name,
    })
    room:moveCardTo(card, Card.PlayerHand, data.from, fk.ReasonJustMove, yinbing.name, nil, false, data.from)
  end,
})

return yinbing
