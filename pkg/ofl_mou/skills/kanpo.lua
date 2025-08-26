local kanpo = fk.CreateSkill({
  name = "ofl_mou__kanpo",
  derived_piles = "$ofl_mou__kanpo",
})

Fk:loadTranslationTable{
  ["ofl_mou__kanpo"] = "看破",
  [":ofl_mou__kanpo"] = "游戏开始时，你摸三张牌，然后你可以将至多三张牌扣置于你的武将牌上，称为“谋”。"..
  "当其他角色使用牌时，你可以移除一张牌名相同的“谋”，然后令此牌无效并摸一张牌。",

  ["#ofl_mou__kanpo-ask"] = "看破：将至多三张牌扣置为“谋”，其他角色使用同名牌时，你可以移去一张同牌名“谋”令之无效",
  ["#ofl_mou__kanpo-invoke"] = "看破：是否移去一张“谋”，令 %dest 使用的%arg无效？",
  ["$ofl_mou__kanpo"] = "谋",

  ["$ofl_mou__kanpo1"] = "敌已计穷势迫，现欲拼死一搏矣。",
  ["$ofl_mou__kanpo2"] = "可笑汝错漏百出，却仍不自知。",
}

kanpo:addEffect(fk.GameStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(kanpo.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(3, kanpo.name)
    if player:isNude() or not player:hasSkill(kanpo.name, true) then return end
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = 3,
      include_equip = true,
      skill_name = kanpo.name,
      prompt = "#ofl_mou__kanpo-ask",
      cancelable = true,
    })
    if #cards > 0 then
      player:addToPile("$ofl_mou__kanpo", cards, false, kanpo.name, player)
    end
  end,
})

kanpo:addEffect(fk.CardUsing, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(kanpo.name) and
      #player:getPile("$ofl_mou__kanpo") > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = kanpo.name,
      pattern = data.card.trueName.."|.|.|$ofl_mou__kanpo",
      prompt = "#ofl_mou__kanpo-invoke::"..target.id..":"..data.card:toLogString(),
      cancelable = true,
      expand_pile = "$ofl_mou__kanpo",
    })
    if #cards > 0 then
      event:setCostData(self, {tos = {target}, cards = cards})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:moveCardTo(event:getCostData(self).cards, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, kanpo.name, nil, true, player)
    data.toCard = nil
    data:removeAllTargets()
    if not player.dead then
      player:drawCards(1, kanpo.name)
    end
  end,
})

return kanpo
