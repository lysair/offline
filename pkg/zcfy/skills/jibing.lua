local jibing = fk.CreateSkill {
  name = "sxfy__jibing",
}

Fk:loadTranslationTable{
  ["sxfy__jibing"] = "集兵",
  [":sxfy__jibing"] = "摸牌阶段开始时，若你的“兵”数不大于X（X为场上势力数），你可以放弃摸牌，改为将牌堆顶两张牌置于你的武将牌上，称为“兵”。"..
  "你可以如手牌般使用“兵”。",

  ["#sxfy__jibing"] = "集兵：你可以使用一张“兵”",
}

jibing:addEffect("viewas", {
  pattern = ".",
  expand_pile = "$mayuanyi_bing",
  derived_piles = "$mayuanyi_bing",
  prompt = "#sxfy__jibing",
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and player:getPileNameOfId(to_select) == "$mayuanyi_bing"
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local c = Fk:getCardById(cards[1])
    local card = Fk:cloneCard(c.name, c.suit, c.number)
    card.skillName = "jibing"
    card:addSubcard(cards[1])
    return card
  end,
  enabled_at_response = function (self, player, response)
    return not response and #player:getPile("$mayuanyi_bing") > 0
  end,
})

jibing:addEffect(fk.EventPhaseStart, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(jibing.name) and player.phase == Player.Draw then
      local kingdoms = {}
      for _, p in ipairs(player.room.alive_players) do
        table.insertIfNeed(kingdoms, p.kingdom)
      end
      return #player:getPile("$mayuanyi_bing") <= #kingdoms
    end
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = jibing.name,
      prompt = "#jibing-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    data.phase_end = true
    player:addToPile("$mayuanyi_bing", player.room:getNCards(2), false, jibing.name)
  end,
})

return jibing
