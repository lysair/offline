local liushang = fk.CreateSkill {
  name = "liushang",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["liushang"] = "流觞",
  [":liushang"] = "锁定技，摸牌阶段，你摸X+1张牌（X为场上存活角色数且至少为3），然后在每名其他角色武将牌上放置一张手牌。其他角色的准备阶段，"..
  "其选择一项：1.获得其“流觞”牌，本回合对你造成伤害时防止之；2.弃置“流觞”牌。",

  ["#liushang-give"] = "流觞：为每名其他角色分配一张“流觞”牌，其准备阶段选择获得或弃置之",
  ["liushang_prey"] = "获得“流觞”牌，防止本回合对%src造成的伤害",
  ["liushang_diecard"] = "弃置“流觞”牌",
}

liushang:addEffect(fk.DrawNCards, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(liushang.name)
  end,
  on_use = function(self, event, target, player, data)
    data.n = math.max(3, #player.room.alive_players) + 1
  end,
})

liushang:addEffect(fk.AfterDrawNCards, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:usedSkillTimes(liushang.name, Player.HistoryPhase) > 0 and
      not player.dead and not player:isKongcheng() and #player.room:getOtherPlayers(player, false) > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = math.min(player:getHandcardNum(), #room:getOtherPlayers(player, false))
    local result = room:askToYiji(player, {
      cards = player:getCardIds("h"),
      targets = room:getOtherPlayers(player, false),
      skill_name = liushang.name,
      min_num = n,
      max_num = n,
      prompt = "#liushang-give",
      single_max = 1,
      skip = true,
    })
    local moves = {}
    for id, ids in pairs(result) do
      if #ids > 0 then
        table.insert(moves, {
          ids = ids,
          from = player,
          to = room:getPlayerById(id),
          toArea = Card.PlayerSpecial,
          specialName = liushang.name,
          moveReason = fk.ReasonJustMove,
          proposer = player,
        })
      end
    end
    room:moveCards(table.unpack(moves))
  end,
})

liushang:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(liushang.name) and target.phase == Player.Start and
      #target:getPile(liushang.name) > 0
  end,
  on_cost = function (self, event, target, player, data)
    event:setCostData(self, {tos = {target}})
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = room:askToChoice(target, {
      choices = {
        "liushang_prey:"..player.id,
        "liushang_diecard",
      },
      skill_name = liushang.name,
    })
    if choice == "liushang_diecard" then
      room:moveCardTo(target:getPile(liushang.name), Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, liushang.name, nil, true, target)
    else
      room:moveCardTo(target:getPile(liushang.name), Card.PlayerHand, target, fk.ReasonJustMove, liushang.name, nil, true, target)
      if not target.dead and not player.dead then
        room:addTableMark(target, "liushang-turn", player.id)
      end
    end
  end,
})

liushang:addEffect(fk.DamageCaused, {
  anim_type = "defensive",
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target and table.contains(target:getTableMark("liushang-turn"), player.id) and data.to == player
  end,
  on_use = function (self, event, target, player, data)
    data:preventDamage()
  end,
})

liushang:addLoseEffect(function (self, player, is_death)
  local room = player.room
  if not table.find(room:getOtherPlayers(player, false), function (p)
    return p:hasSkill(liushang.name, true)
  end) then
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if #p:getPile(liushang.name) > 0 then
        room:moveCardTo(p:getPile(liushang.name), Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile)
      end
    end
  end
end)

return liushang
