local zenrun = fk.CreateSkill {
  name = "sxfy__zenrun",
}

Fk:loadTranslationTable{
  ["sxfy__zenrun"] = "谮润",
  [":sxfy__zenrun"] = "摸牌阶段，你可以改为获得一名其他角色装备区内一张牌。",

  ["#sxfy__zenrun-choose"] = "谮润：你可以改为获得一名其他角色装备区内一张牌",
}

zenrun:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zenrun.name) and player.phase == Player.Draw and
      not data.phase_end and table.find(player.room:getOtherPlayers(player, false), function (p)
        return #p:getCardIds("e") > 0
      end)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return #p:getCardIds("e") > 0
    end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = zenrun.name,
      prompt = "#sxfy__zenrun-choose",
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data.phase_end = true
    local to = event:getCostData(self).tos[1]
    local card = room:askToChooseCard(player, {
      target = to,
      flag = "e",
      skill_name = zenrun.name,
    })
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, zenrun.name, nil, true, player)
  end,
})

return zenrun
