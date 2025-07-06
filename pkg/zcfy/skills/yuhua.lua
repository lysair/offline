local yuhua = fk.CreateSkill {
  name = "sxfy__yuhua",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable {
  ["sxfy__yuhua"] = "羽化",
  [":sxfy__yuhua"] = "锁定技，弃牌阶段开始时，你可以展示任意张非基本牌，令这些牌不计入你的手牌上限。",

  ["#sxfy__yuhua-show"] = "羽化：你可以展示任意张非基本牌，令这些牌不计入手牌上限",
}

yuhua:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yuhua.name) and player.phase == Player.Discard and
      not player:isKongcheng()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = 999,
      include_equip = false,
      skill_name = yuhua.name,
      pattern = ".|.|.|.|.|^basic",
      prompt = "#sxfy__yuhua-show",
      cancelable = true,
    })
    if #cards > 0 then
      player:showCards(cards)
      cards = table.filter(cards, function (id)
        return table.contains(player:getCardIds("h"), id)
      end)
      if #cards > 0 then
        for _, id in ipairs(cards) do
          room:setCardMark(Fk:getCardById(id), "sxfy__yuhua-inhand", 1)
        end
      end
    end
  end,
})

yuhua:addEffect("maxcards", {
  exclude_from = function (self, player, card)
    return card:getMark("sxfy__yuhua-inhand") > 0
  end,
})

return yuhua
