local zenhui = fk.CreateSkill {
  name = "sxfy__zenhui",
}

Fk:loadTranslationTable{
  ["sxfy__zenhui"] = "谮毁",
  [":sxfy__zenhui"] = "当你使用【杀】或锦囊牌时，你可以令一名非目标角色成为此牌使用者。",

  ["#sxfy__zenhui-choose"] = "谮毁：你可以为你使用的%arg改变使用者",
}

zenhui:addEffect(fk.CardUsing, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zenhui.name) and
      (data.card.trueName == "slash" or data.card.type == Card.TypeTrick) and
      table.find(player.room:getOtherPlayers(player, false), function (p)
        return not data.tos or not table.contains(data.tos, p)
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return not data.tos or not table.contains(data.tos, p)
    end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = zenhui.name,
      prompt = "#sxfy__zenhui-choose:::"..data.card:toLogString(),
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    data.from = event:getCostData(self).tos[1]
  end,
})

return zenhui
