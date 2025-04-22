local jicui = fk.CreateSkill {
  name = "ofl__jicui"
}

Fk:loadTranslationTable{
  ['ofl__jicui'] = '急摧',
  ['#ofl__jicui-put'] = '急摧：你需将%arg张牌置于武将牌上直到回合结束',
  ['$ofl__jicui'] = '急摧',
  ['#ofl__jicui_delay'] = '急摧',
  [':ofl__jicui'] = '锁定技，你的回合内，当一名角色使用属性【杀】指定目标后，目标角色需将其X张牌置于武将牌上直到回合结束，此【杀】伤害+1（X为本回合进入过弃牌堆的牌数）。',
}

jicui:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(jicui.name) and data.card.trueName == "slash" and not table.contains({"slash", "stab__slash"}, data.card.name) then
      local turn_event = player.room.logic:getCurrentEvent():findParent(GameEvent.Turn)
      if turn_event and turn_event.data[1] == player then
        local n = 0
        player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
          for _, move in ipairs(e.data) do
            if move.toArea == Card.DiscardPile then
              n = n + #move.moveInfo
            end
          end
        end, Player.HistoryTurn)
        return n > 0
      end
    end
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
    local to = room:getPlayerById(data.to)
    if not to:isNude() then
      local cards
      if #to:getCardIds("he") > n then
        cards = room:askToCards(to, {
          min_num = n,
          max_num = n,
          include_equip = true,
          skill_name = jicui.name,
          cancelable = false,
          prompt = "#ofl__jicui-put:::"..n
        })
      else
        cards = to:getCardIds("he")
      end
      to:addToPile("$ofl__jicui", cards, false, jicui.name, to.id)
    end
  end,
})

jicui:addEffect(fk.TurnEnd, {
  name = "#ofl__jicui_delay",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return #player:getPile("$ofl__jicui") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player.room:moveCardTo(player:getPile("$ofl__jicui"), Card.PlayerHand, player, fk.ReasonJustMove, "ofl__jicui", nil, false, player.id)
  end,
})

return jicui
