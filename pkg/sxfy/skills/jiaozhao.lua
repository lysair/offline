local jiaozhao = fk.CreateSkill {
  name = "sxfy__jiaozhao",
}

Fk:loadTranslationTable{
  ["sxfy__jiaozhao"] = "矫诏",
  [":sxfy__jiaozhao"] = "出牌阶段限一次，你可以令一名其他角色展示两张手牌，然后你可以用一张手牌交换其中一张牌。",

  ["#sxfy__jiaozhao"] = "矫诏：令一名角色展示两张手牌，你可以用一张手牌交换其中一张牌",
  ["#sxfy__jiaozhao-show"] = "矫诏：请展示两张手牌",
  ["#sxfy__jiaozhao-prey"] = "矫诏：获得其中一张牌",
  ["#sxfy__jiaozhao-exchange"] = "矫诏：你可以用一张手牌交换其中一张牌",
}

Fk:addPoxiMethod{
  name = "sxfy__jiaozhao",
  prompt = "#sxfy__jiaozhao-exchange",
  card_filter = function(to_select, selected, data)
    if #selected < 2 then
      if #selected == 0 then
        return true
      else
        if table.contains(data[1][2], selected[1]) then
          return table.contains(data[2][2], to_select)
        else
          return table.contains(data[1][2], to_select)
        end
      end
    end
  end,
  feasible = function(selected)
    return #selected == 2
  end,
}

jiaozhao:addEffect("active", {
  anim_type = "control",
  prompt = "#sxfy__jiaozhao",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(jiaozhao.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player and not to_select:isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local cards = target:getCardIds("h")
    if target:getHandcardNum() > 2 then
      cards = room:askToCards(target, {
        min_num = 2,
        max_num = 2,
        include_equip = false,
        skill_name = jiaozhao.name,
        prompt = "#sxfy__jiaozhao-show",
        cancelable = false,
      })
    end
    target:showCards(cards)
    if player.dead or target.dead then return end
    cards = table.filter(cards, function (id)
      return table.contains(target:getCardIds("h"), id)
    end)
    if #cards == 0 then return end
    if self.extra_data and self.extra_data.sxfy__danxin then
      self.extra_data = nil
      local card = room:askToChooseCard(player, {
        target = target,
        flag = { card_data = {{ target.general, cards }} },
        skill_name = jiaozhao.name,
        prompt = "#sxfy__jiaozhao-prey",
      })
      room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, jiaozhao.name, nil, true, player)
    elseif not player:isKongcheng() then
      local result = room:askToPoxi(player, {
        poxi_type = jiaozhao.name,
        data = {
          { target.general, cards },
          { player.general, player:getCardIds("h") },
        },
        cancelable = true,
      })
      if #result ~= 2 then return end
      local cards1, cards2 = {result[1]}, {result[2]}
      if table.contains(target:getCardIds("h"), result[2]) then
        cards1, cards2 = {result[2]}, {result[1]}
      end
      room:swapCards(player, {
        { target, cards1 },
        { player, cards2 },
      }, jiaozhao.name)
    end
  end,
})

return jiaozhao
