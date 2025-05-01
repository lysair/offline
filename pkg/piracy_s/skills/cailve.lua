local cailve = fk.CreateSkill {
  name = "ofl__cailve",
}

Fk:loadTranslationTable{
  ["ofl__cailve"] = "才略",
  [":ofl__cailve"] = "当你需使用或打出牌时，你可以将“才”如手牌般使用或打出，然后此牌目标角色可以弃置你的一张牌。",

  ["#ofl__cailve"] = "才略：你可以使用或打出“才”，目标角色可以弃置你一张牌",
  ["#cailve-discard"] = "才略：是否弃置 %src 一张牌？",
}

cailve:addEffect("viewas", {
  pattern = ".",
  prompt = "#ofl__cailve",
  expand_pile = function(self, player)
    return player:getPile("$ofl__qibian")
  end,
  card_filter = function(self, player, to_select, selected)
    if #selected == 0 and table.contains(player:getPile("$ofl__qibian"), to_select) then
      local card = Fk:getCardById(to_select)
      if Fk.currentResponsePattern == nil then
        return player:canUse(card) and not player:prohibitUse(card)
      else
        return Exppattern:Parse(Fk.currentResponsePattern):match(card)
      end
    end
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    return Fk:getCardById(cards[1])
  end,
  after_use = function (self, player, use)
    local room = player.room
    if not player.dead and not player:isNude() and use.tos and #use.tos > 0 then
      room:sortByAction(use.tos)
      for _, p in ipairs(use.tos) do
        if not p.dead and
          room:askToSkillInvoke(p, {
          skill_name = cailve.name,
          prompt = "#cailve-discard:"..player.id,
        }) then
          room:doIndicate(p, {player})
          if p == player then
            room:askToDiscard(player, {
              min_num = 1,
              max_num = 1,
              include_equip = true,
              skill_name = cailve.name,
              cancelable = false,
            })
          else
            local card = room:askToChooseCard(p, {
              target = player,
              flag = "he",
              skill_name = cailve.name,
            })
            room:throwCard(card, cailve.name, player, player)
          end
        end
      end
    end
  end,

  enabled_at_play = function(self, player)
    return #player:getPile("$ofl__qibian") > 0
  end,
  enabled_at_response = function(self, player, response)
    return #player:getPile("$ofl__qibian") > 0
  end,
})

return cailve
