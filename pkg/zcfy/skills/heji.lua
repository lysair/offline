local heji = fk.CreateSkill {
  name = "sxfy__heji",
}

Fk:loadTranslationTable{
  ["sxfy__heji"] = "合击",
  [":sxfy__heji"] = "当一名角色使用的【决斗】或红色【杀】结算结束后，你可以对其中一名目标角色使用一张无距离次数限制的"..
  "【杀】或【决斗】，然后你摸一张牌。",

  ["#sxfy__heji-use"] = "合击：你可以对其中一名目标使用【杀】或者【决斗】，然后摸一张牌",
}

heji:addEffect(fk.CardUseFinished, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(heji.name) and
      (data.card.trueName == "duel" or (data.card.trueName == "slash" and data.card.color == Card.Red)) and
      table.find(data.tos, function (p)
        return p ~= player and not player.dead
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local use = room:askToUseCard(player, {
      skill_name = heji.name,
      pattern = "slash,duel",
      prompt = "#sxfy__heji-use",
      extra_data = {
        bypass_distances = true,
        bypass_times = true,
        exclusive_targets = table.map(data.tos, Util.IdMapper),
      }
    })
    if use then
      use.extraUse = true
      event:setCostData(self, {extra_data = use})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:useCard(event:getCostData(self).extra_data)
    if not player.dead then
      player:drawCards(1, heji.name)
    end
  end,
})

return heji
