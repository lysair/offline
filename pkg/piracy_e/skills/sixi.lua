local sixi = fk.CreateSkill {
  name = "sixi",
}

Fk:loadTranslationTable{
  ["sixi"] = "伺袭",
  [":sixi"] = "出牌阶段限两次，你可以与一名角色拼点：若你赢，你可以视为使用一张刺【杀】；若你没赢，其计算与你的距离+1直到你下回合开始。"..
  "当一次拼点结算后，你可以获得所有拼点牌。",

  ["#sixi"] = "伺袭：你可以拼点，若赢你可以视为使用刺【杀】，若没赢其计算与你距离+1",
  ["#sixi-slash"] = "伺袭：你可以视为使用刺【杀】",
  ["#sixi-prey"] = "伺袭：是否获得这些拼点牌？",
}

sixi:addEffect("active", {
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  prompt = "#sixi",
  can_use = function(self, player)
    return player:usedEffectTimes(self.name, Player.HistoryPhase) < 2
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and player:canPindian(to_select)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local pindian = player:pindian({target}, sixi.name)
    if player.dead then return end
    if pindian.results[target].winner == player then
      room:askToUseVirtualCard(player, {
        name = "stab__slash",
        skill_name = sixi.name,
        prompt = "#sixi-slash",
        cancelable = true,
        extra_data = {
          bypass_times = true,
          extraUse = true,
        }
      })
    elseif not target.dead then
      room:addTableMark(player, sixi.name, target.id)
    end
  end,
})

sixi:addEffect(fk.TurnStart, {
  can_refresh = function (self, event, target, player, data)
    return target == player
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(player, sixi.name, 0)
  end,
})

sixi:addEffect("distance", {
  correct_func = function (self, from, to)
    return #table.filter(to:getTableMark(sixi.name), function (id)
      return from.id == id
    end)
  end,
})

sixi:addEffect(fk.PindianFinished, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(sixi.name) then
      if data.fromCard and player.room:getCardArea(data.fromCard) == Card.Processing then
        return true
      end
      for _, result in pairs(data.results) do
        if result.toCard and player.room:getCardArea(result.toCard) == Card.Processing then
          return true
        end
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = sixi.name,
      prompt = "#sixi-prey",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = {}
    if data.fromCard and room:getCardArea(data.fromCard) == Card.Processing then
      table.insertTableIfNeed(cards, Card:getIdList(data.fromCard))
    end
    for _, result in pairs(data.results) do
      if result.toCard and room:getCardArea(result.toCard) == Card.Processing then
        table.insertTableIfNeed(cards, Card:getIdList(result.toCard))
      end
    end
    room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, sixi.name, nil, true, player)
  end,
})

return sixi
