local qingyuan = fk.CreateSkill {
  name = "sxfy__qingyuan",
  tags = { Skill.Compulsory, },
}

Fk:loadTranslationTable{
  ["sxfy__qingyuan"] = "轻缘",
  [":sxfy__qingyuan"] = "锁定技，准备阶段，若你已受伤，你获得一名体力值不小于你的其他角色的一张手牌；"..
  "结束阶段，若你未受伤，你获得一名体力值不大于你的角色的一张手牌。",

  ["#sxfy__qingyuan-choose"] = "轻缘：获得一名角色的一张手牌",
}

qingyuan:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(qingyuan.name) then
      if player.phase == Player.Start then
        return player:isWounded() and
          table.find(player.room:getOtherPlayers(player, false), function (p)
            return p.hp >= player.hp and not p:isKongcheng()
          end)
      elseif player.phase == Player.Finish then
        return not player:isWounded() and
          table.find(player.room:getOtherPlayers(player, false), function (p)
            return p.hp <= player.hp and not p:isKongcheng()
          end)
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    if player.phase == Player.Start then
      targets = table.filter(room:getOtherPlayers(player, false), function (p)
        return p.hp >= player.hp and not p:isKongcheng()
      end)
    elseif player.phase == Player.Finish then
      targets = table.filter(room:getOtherPlayers(player, false), function (p)
        return p.hp <= player.hp and not p:isKongcheng()
      end)
    end
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = qingyuan.name,
      prompt = "#sxfy__qingyuan-choose",
      cancelable = false,
    })[1]
    local card = room:askToChooseCard(player, {
      target = to,
      flag = "h",
      skill_name = qingyuan.name,
    })
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, qingyuan.name, nil, false, player)
  end,
})

return qingyuan