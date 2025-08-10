local xianli = fk.CreateSkill{
  name = "ofl__xianli",
}

Fk:loadTranslationTable{
  ["ofl__xianli"] = "娴丽",
  [":ofl__xianli"] = "每回合限两次，当你失去【闪】时，你可以获得当前回合角色的一张牌。",

  ["#ofl__xianli-invoke"] = "娴丽：你可以获得 %dest 的一张牌",
}

xianli:addEffect(fk.AfterCardsMove, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(xianli.name) and
      player:usedSkillTimes(xianli.name, Player.HistoryTurn) < 2 then
      for _, move in ipairs(data) do
        if move.from == player then
          for _, info in ipairs(move.moveInfo) do
            if Fk:getCardById(info.cardId, true).trueName == "jink" then
              return player.room.current and not player.room.current.dead and not player.room.current:isNude() and
                (player.room.current ~= player or #player:getCardIds("e") > 0)
            end
          end
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = xianli.name,
      prompt = "#ofl__xianli-invoke::"..room.current.id,
    }) then
      event:setCostData(self, {tos = {room.current}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = room:askToChooseCard(player, {
      target = room.current,
      flag = room.current == player and "e" or "he",
      skill_name = xianli.name,
    })
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, xianli.name, nil, false, player)
  end,
})

return xianli
