local mutao = fk.CreateSkill {
  name = "sxfy__mutao",
}

Fk:loadTranslationTable{
  ["sxfy__mutao"] = "募讨",
  [":sxfy__mutao"] = "准备阶段，你可以令一名其他角色展示所有手牌，若其中有【杀】，你对其造成1点伤害。",

  ["#sxfy__mutao-choose"] = "募讨：令一名角色展示手牌，若其中有【杀】，你对其造成1点伤害",
}

mutao:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(mutao.name) and player.phase == Player.Start and
      table.find(player.room:getOtherPlayers(player, false), function (p)
        return not p:isKongcheng()
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(player.room:getOtherPlayers(player, false), function (p)
        return not p:isKongcheng()
      end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = mutao.name,
      prompt = "#sxfy__mutao-choose",
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
    local yes = table.find(to:getCardIds("h"), function (id)
      return Fk:getCardById(id).trueName == "slash"
    end)
    to:showCards(to:getCardIds("h"))
    if yes and not to.dead then
      room:damage{
        from = player,
        to = to,
        damage = 1,
        skillName = mutao.name,
      }
    end
  end,
})

return mutao
