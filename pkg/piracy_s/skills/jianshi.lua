local jianshi = fk.CreateSkill {
  name = "ofl__jianshi",
}

Fk:loadTranslationTable{
  ["ofl__jianshi"] = "鉴势",
  [":ofl__jianshi"] = "结束阶段，若所有其他角色手牌数均不小于体力值，你可以选择一项：1.获得所有其他角色各一张手牌；2.令所有其他角色"..
  "将手牌数调整至体力值。",

  ["ofl__jianshi_prey"] = "获得其他角色各一张手牌",
  ["ofl__jianshi_discard"] = "所有其他角色将手牌调整至体力值",
}

jianshi:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jianshi.name) and player.phase == Player.Finish and
      table.every(player.room:getOtherPlayers(player, false), function (p)
        return p:getHandcardNum() >= p.hp
      end)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local choices = {"ofl__jianshi_discard", "Cancel"}
    if table.find(room:getOtherPlayers(player, false), function (p)
      return not p:isKongcheng()
    end) then
      table.insert(choices, 1, "ofl__jianshi_prey")
    end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = jianshi.name,
      prompt = "#ofl__jianshi-choice",
      all_choices = {"ofl__jianshi_prey", "ofl__jianshi_discard", "Cancel"},
    })
    if choice ~= "Cancel" then
      event:setCostData(self, {tos = room:getOtherPlayers(player), choice = choice})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = event:getCostData(self).choice
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if not p.dead then
        if choice == "ofl__jianshi_prey" then
          if player.dead then return end
          if not p:isKongcheng() then
            local card = room:askToChooseCard(player, {
              target = p,
              flag = "h",
              skill_name = jianshi.name,
            })
            room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, jianshi.name, nil, false, player)
          end
        else
          local n = p:getHandcardNum() - p.hp
          if n > 0 then
            room:askToDiscard(p, {
              min_num = n,
              max_num = n,
              include_equip = false,
              skill_name = jianshi.name,
              cancelable = false,
            })
          elseif n < 0 then
            p:drawCards(-n, jianshi.name)
          end
        end
      end
    end
  end,
})

return jianshi
