local cuijian = fk.CreateSkill {
  name = "shzj_xiangfan__cuijian",
}

Fk:loadTranslationTable{
  ["shzj_xiangfan__cuijian"] = "摧坚",
  [":shzj_xiangfan__cuijian"] = "出牌阶段限一次，你可以令一名其他角色展示所有手牌，然后交给你所有【闪】和防具牌，若你未因此获得牌，你摸两张牌。",

  ["#shzj_xiangfan__cuijian"] = "摧坚：令一名角色展示手牌并将所有【闪】和防具交给你，若未获得牌则摸两张牌",

  ["$shzj_xiangfan__cuijian1"] = "试问瓮中鼠辈，谁可覆巢余生！",
  ["$shzj_xiangfan__cuijian2"] = "狭路相逢，唯克坚死战，无躲闪偷生！"
}

cuijian:addEffect("active", {
  anim_type = "control",
  prompt = "#shzj_xiangfan__cuijian",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(cuijian.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player and not to_select:isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    target:showCards(target:getCardIds("h"))
    local cards = table.filter(target:getCardIds("he"), function(id)
      return Fk:getCardById(id).trueName == "jink" or Fk:getCardById(id).sub_type == Card.SubtypeArmor
    end)
    if player.dead then return end
    if #cards == 0 then
      player:drawCards(2, cuijian.name)
    else
      room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonGive, cuijian.name, nil, true, target)
    end
  end,
})

return cuijian
