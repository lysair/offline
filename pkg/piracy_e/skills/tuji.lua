local tuji = fk.CreateSkill {
  name = "ofl__tuji",
}

Fk:loadTranslationTable{
  ["ofl__tuji"] = "突击",
  [":ofl__tuji"] = "回合开始时，你可以观看一名其他角色的手牌并弃置其中一张牌。",

  ["#ofl__tuji-choose"] = "突击：你可以观看一名角色的手牌并弃置其中一张牌",
}

tuji:addEffect(fk.TurnStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(tuji.name) and
      table.find(player.room:getOtherPlayers(player, false), function (p)
        return not p:isKongcheng()
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return not p:isKongcheng()
    end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = tuji.name,
      prompt = "#ofl__tuji-choose",
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
    local cards = room:askToChooseCard(player, {
      target = to,
      flag = { card_data = {{ to.general, to:getCardIds("h") }} },
      skill_name = tuji.name,
    })
    room:throwCard(cards, tuji.name, to, player)
  end,
})

return tuji
