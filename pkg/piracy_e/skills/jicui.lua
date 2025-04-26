local jicui = fk.CreateSkill {
  name = "ofl__jicui",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl__jicui"] = "急摧",
  [":ofl__jicui"] = "锁定技，你的回合内，当一名角色使用属性【杀】指定目标后，目标角色需将其X张牌置于武将牌上直到回合结束，此【杀】伤害+1"..
  "（X为本回合进入过弃牌堆的牌数）。",

  ["#ofl__jicui-put"] = "急摧：你需将%arg张牌置于武将牌上直到回合结束",
  ["$ofl__jicui"] = "急摧",
}

jicui:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(jicui.name) and data.card.trueName == "slash" and
      not table.contains({"slash", "stab__slash"}, data.card.name) and
      player.room.current == player and
      #player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
        for _, move in ipairs(e.data) do
          if move.toArea == Card.DiscardPile then
            return true
          end
        end
      end, Player.HistoryTurn) > 0
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    data.additionalDamage = (data.additionalDamage or 0) + 1
    local n = 0
    room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
      for _, move in ipairs(e.data) do
        if move.toArea == Card.DiscardPile then
          n = n + #move.moveInfo
        end
      end
    end, Player.HistoryTurn)
    if not data.to:isNude() then
      local cards = data.to:getCardIds("he")
      if #cards > n then
        cards = room:askToCards(data.to, {
          min_num = n,
          max_num = n,
          include_equip = true,
          skill_name = jicui.name,
          cancelable = false,
          prompt = "#ofl__jicui-put:::"..n
        })
      end
      data.to:addToPile("$ofl__jicui", cards, false, jicui.name, data.to)
    end
  end,
})

jicui:addEffect(fk.TurnEnd, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return #player:getPile("$ofl__jicui") > 0
  end,
  on_use = function (self, event, target, player, data)
    player.room:moveCardTo(player:getPile("$ofl__jicui"), Card.PlayerHand, player, fk.ReasonJustMove)
  end,
})

return jicui
