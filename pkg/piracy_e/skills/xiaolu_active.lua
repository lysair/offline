local xiaolu_active = fk.CreateSkill {
  name = "ofl__xiaolu&",
}

Fk:loadTranslationTable{
  ["ofl__xiaolu&"] = "宵赂",
  [":ofl__xiaolu&"] = "出牌阶段限一次，你可以交给韩悝一张牌，然后视为对另一名角色使用一张仅指定该角色为目标的普通锦囊牌。",

  ["#ofl__xiaolu&"] = "宵赂：你可以交给韩悝一张牌，然后视为对另一名角色使用一张普通锦囊牌",
  ["#ofl__xiaolu-use"] = "宵赂：视为对一名角色使用一张锦囊牌",
}

local U = require "packages/utility/utility"

xiaolu_active:addEffect("active", {
  mute = true,
  card_num = 1,
  target_num = 1,
  prompt = "#ofl__xiaolu&",
  can_use = function(self, player)
    return table.find(Fk:currentRoom().alive_players, function (p)
      return p:hasSkill("ofl__xiaolu") and p:usedSkillTimes("ofl__xiaolu", Player.HistoryPhase) == 0
    end)
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0
  end,
  target_filter = function(self, player, to_select, selected, cards)
    return #selected == 0 and to_select ~= player and to_select:hasSkill("ofl__xiaolu") and
    to_select:usedSkillTimes("ofl__xiaolu", Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    target:broadcastSkillInvoke("ofl__xiaolu")
    room:notifySkillInvoked(target, "ofl__xiaolu", "support")
    target:addSkillUseHistory("ofl__xiaolu", 1)
    room:moveCardTo(effect.cards, Card.PlayerHand, target, fk.ReasonGive, "ofl__xiaolu", nil, false, player)
    if player.dead then return end
    if not room:getBanner("ofl__xiaolu") then
      room:setBanner("ofl__xiaolu", U.getUniversalCards(room, "t"))
    end
    local success, dat = room:askToUseActiveSkill(player, {
      skill_name = "ofl__xiaolu_viewas",
      prompt = "#ofl__xiaolu-use",
      cancelable = true,
      extra_data = {
        expand_pile = room:getBanner("ofl__xiaolu"),
        exclusive_targets = table.map(room:getOtherPlayers(target), Util.IdMapper),
      },
    })
    if success and dat then
      local card = Fk:cloneCard(Fk:getCardById(dat.cards[1]).name)
      card.skillName = "ofl__xiaolu"
      room:useCard{
        from = player,
        tos = dat.targets,
        card = card,
      }
    end
  end,
})

return xiaolu_active
