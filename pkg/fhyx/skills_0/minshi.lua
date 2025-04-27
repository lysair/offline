local minshi = fk.CreateSkill {
  name = "ofl_shiji__minshi"
}

Fk:loadTranslationTable{
  ['ofl_shiji__minshi'] = '悯施',
  ['#ofl_shiji__minshi-active'] = '悯施：观看额外牌堆的三张基本牌，任意交给手牌数小于体力值的角色',
  ['@$fhyx_extra_pile'] = '额外牌堆',
  ['#ofl_shiji__minshi-give'] = '悯施：分配这些牌，每有一名没获得牌的目标角色，你失去1点体力',
  [':ofl_shiji__minshi'] = '出牌阶段限一次，你可以选择所有手牌数少于体力值的角色并观看额外牌堆中至多三张基本牌，然后你可以依次将其中任意张牌交给任意角色。然后你选择的角色中每有一名未获得牌的角色，你失去1点体力。',
}

minshi:addEffect('active', {
  anim_type = "support",
  card_num = 0,
  target_num = 0,
  prompt = function(self, player)
    return "#ofl_shiji__minshi-active"
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(minshi.name, Player.HistoryPhase) == 0 and
      table.find(Fk:currentRoom().alive_players, function(p)
        return p:getHandcardNum() < p.hp
      end) and
      table.find(Fk:currentRoom():getBanner("@$fhyx_extra_pile"), function(id)
        return Fk:getCardById(id).type == Card.TypeBasic
      end)
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, player, room, effect)
    local targets = table.filter(room:getAlivePlayers(), function(p)
      return p:getHandcardNum() < p.hp
    end)
    if #targets == 0 then return end
    room:doIndicate(player.id, table.map(targets, Util.IdMapper))
    local cards = table.filter(room:getBanner("@$fhyx_extra_pile"), function(id)
      return Fk:getCardById(id).type == Card.TypeBasic
    end)
    cards = table.random(cards, 3)
    if #cards == 0 then return end
    local result = room:askToYiji(player, {
      targets = targets,
      cards = cards,
      skill_name = minshi.name,
      min_num = 1,
      max_num = #cards,
      prompt = "#ofl_shiji__minshi-give",
      expand_pile = cards
    })
    local n = #table.filter(targets, function(p)
      return #result[tostring(p.id)] == 0
    end)
    if n > 0 and not player.dead then
      room:loseHp(player, n, minshi.name)
    end
  end,

  on_acquire = function (self, player, is_start)
    PrepareExtraPile(player.room)
  end,
})

minshi:addEffect(fk.AfterCardsMove, {
  can_refresh = function(self, event, player, data)
    if player.seat == 1 then
      for _, move in ipairs(data) do
        for _, info in ipairs(move.moveInfo) do
          if player.room:getBanner("fhyx_extra_pile") and
            table.contains(player.room:getBanner("fhyx_extra_pile"), info.cardId) then
            return true
          end
        end
      end
    end
  end,
  on_refresh = function(self, event, player)
    SetFhyxExtraPileBanner(player.room)
  end,
})

return minshi
