local qichu = fk.CreateSkill{
  name = "ofl__qichu",
}

Fk:loadTranslationTable{
  ["ofl__qichu"] = "七出",
  [":ofl__qichu"] = "每名其他角色的回合限一次，当你需要使用或打出一张基本牌时，你可以观看牌堆顶的两张牌，然后可以使用或打出其中一张你需要的基本牌。",

  ["#ofl__qichu"] = "七出：你可以使用或打出其中你需要的基本牌",
}

qichu:addEffect("viewas", {
  anim_type = "special",
  click_count = true,
  pattern = ".|.|.|.|.|basic",
  prompt = "#ofl__qichu",
  expand_pile = function(self, player)
    local ids = {}
    for i = 1, 2, 1 do
      if i > #Fk:currentRoom().draw_pile then break end
      table.insert(ids, Fk:currentRoom().draw_pile[i])
    end
    return ids
  end,
  card_filter = function(self, player, to_select, selected)
    if #selected == 0 and table.contains(Fk:currentRoom().draw_pile, to_select) then
      local card = Fk:getCardById(to_select)
      if card.type == Card.TypeBasic then
        if Fk.currentResponsePattern == nil then
          return player:canUse(card) and not player:prohibitUse(card)
        else
          return Exppattern:Parse(Fk.currentResponsePattern):match(card)
        end
      end
    end
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    return Fk:getCardById(cards[1])
  end,
  enabled_at_play = Util.FalseFunc,
  enabled_at_response = function(self, player, response)
    return Fk:currentRoom().current ~= player and
      player:usedSkillTimes(qichu.name, Player.HistoryTurn) == 0 and
      #player:getViewAsCardNames(qichu.name, Fk:getAllCardNames("b")) > 0
  end,
})

qichu:addAI(nil, "vs_skill")

return qichu
