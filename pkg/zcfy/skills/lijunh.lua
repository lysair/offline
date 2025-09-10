local lijunh = fk.CreateSkill {
  name = "lijunh",
}

Fk:loadTranslationTable{
  ["lijunh"] = "励军",
  [":lijunh"] = "准备阶段，你可以展示至多体力值名角色各一张手牌，目标角色依次选择一项：1.立即使用之；2.弃置之。",

  ["#lijunh-choose"] = "励军：展示至多%arg名角色各一张手牌，这些角色选择立即使用或弃置此牌",
  ["#lijunh-use"] = "励军：使用这张牌，否则将弃置之",
}

lijunh:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(lijunh.name) and player.phase == Player.Start and
      player.hp > 0 and
      table.find(player.room.alive_players, function (p)
        return not p:isKongcheng()
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function (p)
      return not p:isKongcheng()
    end)
    local tos = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = player.hp,
      targets = targets,
      skill_name = lijunh.name,
      prompt = "#lijunh-choose:::"..player.hp,
      cancelable = true,
    })
    if #tos > 0 then
      room:sortByAction(tos)
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local tos = event:getCostData(self).tos
    local mapper = {}
    for _, p in ipairs(tos) do
      if player.dead then break end
      if not p.dead and not p:isKongcheng() then
        local card = room:askToChooseCard(player, {
          target = p,
          flag = "h",
          skill_name = lijunh.name,
        })
        mapper[p] = card
        p:showCards(card)
      end
    end
    for _, p in ipairs(tos) do
      if not p.dead and mapper[p] and table.contains(p:getCardIds("h"), mapper[p]) then
        if not room:askToUseRealCard(p, {
          pattern = {mapper[p]},
          skill_name = lijunh.name,
          prompt = "#lijunh-use",
          extra_data = {
            bypass_times = true,
            extraUse = true,
          },
        }) and
        not p:prohibitDiscard(mapper[p]) then
          room:throwCard(mapper[p], lijunh.name, p, p)
        end
      end
    end
  end,
})

return lijunh