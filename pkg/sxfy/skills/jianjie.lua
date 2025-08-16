local jianjie = fk.CreateSkill {
  name = "sxfy__jianjie",
}

Fk:loadTranslationTable{
  ["sxfy__jianjie"] = "荐杰",
  [":sxfy__jianjie"] = "准备阶段，你可以展示至多三名角色各一张牌，这些角色依次可以将其红色展示牌当【火攻】、黑色展示牌当【铁索连环】使用。",

  ["#sxfy__jianjie-choose"] = "荐杰：展示至多三名角色各一张牌，其可以将红色牌当【火攻】、黑色牌当【铁索连环】使用",
  ["#sxfy__jianjie-use"] = "荐杰：你可以将%arg当【%arg2】使用",
}

jianjie:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jianjie.name) and player.phase == Player.Draw and
      table.find(player.room.alive_players, function(p)
        return not p:isNude()
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function(p)
      return not p:isNude()
    end)
    local tos = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 3,
      prompt = "#sxfy__jianjie-choose",
      skill_name = jianjie.name,
    })
    if #tos > 0 then
      room:sortByAction(tos)
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = event:getCostData(self).tos or {}
    local result = {}
    for _, p in ipairs(targets) do
      if player.dead then break end
      if not p.dead and not p:isNude() then
        local id = room:askToChooseCard(player, {
          target = p,
          flag = "he",
          skill_name = jianjie.name,
        })
        if Fk:getCardById(id).color ~= Card.NoColor then
          result[p] = id
        end
        p:showCards(id)
      end
    end
    for _, p in ipairs(targets) do
      if not p.dead and result[p] and table.contains(p:getCardIds("he"), result[p]) then
        local card = Fk:getCardById(result[p])
        local name = card.color == Card.Red and "fire_attack" or "iron_chain"
        room:askToUseVirtualCard(p, {
          name = name,
          skill_name = jianjie.name,
          prompt = "#sxfy__jianjie-use:::"..card:toLogString()..":"..name,
          cancelable = true,
          card_filter = {
            n = 1,
            pattern = tostring(Exppattern{ id = {result[p]} }),
          },
        })
      end
    end
  end,
})

return jianjie
