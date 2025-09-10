
local didao = fk.CreateSkill{
  name = "ofl_tx__didao",
}
Fk:loadTranslationTable{
  ["ofl_tx__didao"] = "地道",
  [":ofl_tx__didao"] = "当一名角色的判定牌生效前，你可以打出一张牌代替之，若与原判定牌颜色相同，你摸一张牌。",

  ["#ofl_tx__didao-ask"] = "地道：你可以打出一张牌代替 %dest 的“%arg”判定",

  ["$ofl_tx__didao1"] = "违吾咒者，倾死灭亡！",
  ["$ofl_tx__didao2"] = "咒宝符命，速显威灵！",
}

didao:addEffect(fk.AskForRetrial, {
  didao = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(didao.name) and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local ids = table.filter(table.connect(player:getHandlyIds(), player:getCardIds("e")), function (id)
      return not player:prohibitResponse(Fk:getCardById(id))
    end)
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      skill_name = didao.name,
      include_equip = true,
      pattern = tostring(Exppattern{ id = ids }),
      prompt = "#ofl_tx__didao-ask::"..target.id..":"..data.reason,
      cancelable = true,
      expand_pile = table.filter(ids, function (id)
        return not table.contains(player:getCardIds("he"), id)
      end)
    })
    if #cards > 0 then
      event:setCostData(self, {cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = Fk:getCardById(event:getCostData(self).cards[1])
    local yes = data.card and card:compareColorWith(data.card)
    room:changeJudge{
      card = card,
      player = player,
      data = data,
      skillName = didao.name,
      response = true,
    }
    if yes and not player.dead then
      player:drawCards(1, didao.name)
    end
  end,
})

return didao
