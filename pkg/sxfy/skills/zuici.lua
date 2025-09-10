local zuici = fk.CreateSkill {
  name = "sxfy__zuici",
}

Fk:loadTranslationTable{
  ["sxfy__zuici"] = "罪辞",
  [":sxfy__zuici"] = "当你受到伤害后，你可以将场上一张牌移至伤害来源对应的区域。",

  ["#sxfy__zuici-choose"] = "罪辞：你可以将场上一张牌移至 %dest 对应的区域",
}

zuici:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zuici.name) and
      data.from and not data.from.dead and
      table.find(player.room:getOtherPlayers(data.from, false), function (p)
        return p:canMoveCardsInBoardTo(data.from)
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(data.from, false), function (p)
      return p:canMoveCardsInBoardTo(data.from)
    end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = self.name,
      prompt = "#sxfy__zuici-choose::"..data.from.id,
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
    room:askToMoveCardInBoard(player, {
      target_one = to,
      target_two = data.from,
      skill_name = zuici.name,
      move_from = to,
    })
  end,
})

return zuici
