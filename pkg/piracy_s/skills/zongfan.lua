local zongfan = fk.CreateSkill {
  name = "ofl__zongfan",
  tags = { Skill.Wake },
}

Fk:loadTranslationTable{
  ["ofl__zongfan"] = "纵反",
  [":ofl__zongfan"] = "觉醒技，回合结束时，若你本回合发动〖谋逆〗且有角色进入濒死状态，你交给一名其他角色任意张牌，加X点体力上限并回复X点体力"..
  "（X为你交给该角色的牌数且最多为5），失去〖谋逆〗，获得〖战孤〗。",

  ["#ofl__zongfan-give"] = "纵反：交给一名其他角色任意张牌，你加等量体力上限并回复等量体力",
}

zongfan:addEffect(fk.TurnEnd, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zongfan.name) and
      player:usedSkillTimes(zongfan.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    return player:usedSkillTimes("ofl__mouni", Player.HistoryTurn) > 0 and
      #player.room.logic:getEventsOfScope(GameEvent.Dying, 1, Util.TrueFunc, Player.HistoryTurn) > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if not player:isNude() then
      local to, cards = room:askToChooseCardsAndPlayers(player, {
        min_card_num = 1,
        max_card_num = 999,
        min_num = 1,
        max_num = 1,
        targets = room:getOtherPlayers(player, false),
        skill_name = zongfan.name,
        prompt = "#ofl__zongfan-give",
        cancelable = true,
      })
      if #to > 0 and #cards > 0 then
        room:moveCardTo(cards, Card.PlayerHand, to[1], fk.ReasonGive, zongfan.name, nil, false, player)
        local n = math.min(#cards, 5)
        if not player.dead then
          room:changeMaxHp(player, n)
        end
        if not player.dead and player:isWounded() then
          room:recover{
            who = player,
            num = n,
            recoverBy = player,
            skillName = zongfan.name,
          }
        end
      end
    end
    if not player.dead then
      room:handleAddLoseSkills(player, "-ofl__mouni|ofl__zhangu")
    end
  end,
})

return zongfan
