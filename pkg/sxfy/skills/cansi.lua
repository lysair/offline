local cansi = fk.CreateSkill {
  name = "sxfy__cansi",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["sxfy__cansi"] = "残肆",
  [":sxfy__cansi"] = "锁定技，准备阶段，你令攻击范围内一名角色获得你一张牌，然后你依次视为对其使用【杀】和【决斗】。",

  ["#sxfy__cansi-choose"] = "残肆：令一名角色获得你的一张牌，你视为对其使用【杀】和【决斗】",
  ["#sxfy__cansi-prey"] = "残肆：获得 %src 一张牌，其将视为对你使用【杀】和【决斗】！",
}

cansi:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(cansi.name) and player.phase == Player.Start and
      not player:isNude() and
      table.find(player.room:getOtherPlayers(player, false), function (p)
        return player:inMyAttackRange(p)
      end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
        return player:inMyAttackRange(p)
    end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = self.name,
      prompt = "#sxfy__cansi-choose",
      cancelable = false,
    })[1]
    local card = room:askToChooseCard(to, {
      target = player,
      flag = "he",
      skill_name = cansi.name,
      prompt = "#sxfy__cansi-prey:"..player.id,
    })
    room:moveCardTo(card, Card.PlayerHand, to, fk.ReasonPrey, cansi.name, nil, false, to)
    for _, name in ipairs({"slash", "duel"}) do
      if player.dead or to.dead then return end
      room:useVirtualCard(name, nil, player, to, cansi.name, true)
    end
  end,
})

return cansi
