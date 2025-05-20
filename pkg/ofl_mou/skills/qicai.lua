local qicai = fk.CreateSkill {
  name = "ofl_mou__qicai",
}

Fk:loadTranslationTable{
  ["ofl_mou__qicai"] = "奇才",
  [":ofl_mou__qicai"] = "你使用锦囊牌无距离限制。出牌阶段限一次，你可以将一张装备牌展示并交给一名其他角色，然后其选择一项：1.展示并交给你"..
  "两张非装备牌；2.你从额外牌堆随机获得两张普通锦囊牌。",

  ["#ofl_mou__qicai"] = "奇才：将一张装备牌交给一名角色，其选择交给你两张非装备牌或令你从额外牌堆获得两张普通锦囊牌",
  ["#ofl_mou__qicai-give"] = "奇才：交给 %src 两张非装备牌，或点“取消”令其从额外牌堆获得两张普通锦囊牌",

  ["$ofl_mou__qicai1"] = "奇巧之器，当出于奇巧之人。",
  ["$ofl_mou__qicai2"] = "尽奇思，毕全才。",
}

local U = require "packages/offline/ofl_util"

qicai:addEffect("active", {
  anim_type = "control",
  prompt = "#ofl_mou__qicai",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(qicai.name, Player.HistoryPhase) == 0
  end,
  card_filter = function (self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).type == Card.TypeEquip
  end,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    if table.contains(player:getCardIds("h"), effect.cards[1]) then
      player:showCards(effect.cards)
      if player.dead or target.dead or not table.contains(player:getCardIds("h"), effect.cards[1]) then return end
    end
    room:moveCardTo(effect.cards, Card.PlayerHand, target, fk.ReasonGive, qicai.name, nil, true, player)
    if player.dead or target.dead then return end
    local cards = table.filter(target:getCardIds("h"), function (id)
      return Fk:getCardById(id).type ~= Card.TypeEquip
    end)
    local cards2 = table.filter(room:getBanner("@$fhyx_extra_pile"), function(id)
      return Fk:getCardById(id):isCommonTrick()
    end)
    if #cards > 0 then
      local cancelable = true
      if #cards2 == 0 then
        cancelable = false
      end
      cards = room:askToCards(target, {
        min_num = 2,
        max_num = 2,
        include_equip = false,
        skill_name = qicai.name,
        pattern = ".|.|.|.|.|^equip",
        prompt = "#ofl_mou__qicai-give:"..player.id,
        cancelable = cancelable,
      })
      if #cards > 0 then
        target:showCards(cards)
        if player.dead or target.dead then return end
        cards = table.filter(cards, function (id)
          return table.contains(target:getCardIds("h"), id)
        end)
        if #cards == 0 then return end
        room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonGive, qicai.name, nil, true, target)
      else
        room:moveCardTo(table.random(cards2, 2), Card.PlayerHand, player, fk.ReasonJustMove, qicai.name, nil, true, player)
      end
    elseif #cards2 > 0 then
      room:moveCardTo(table.random(cards2, 2), Card.PlayerHand, player, fk.ReasonJustMove, qicai.name, nil, true, player,
        MarkEnum.DestructIntoDiscard)
    end
  end,
})

qicai:addEffect("targetmod", {
  bypass_distances = function(self, player, skill, card)
    return player:hasSkill(qicai.name) and card and card.type == Card.TypeTrick
  end,
})

qicai:addAcquireEffect(function (self, player, is_start)
  U.PrepareExtraPile(player.room)
end)

return qicai
