local mouni = fk.CreateSkill {
  name = "ofl__mouni",
}

Fk:loadTranslationTable{
  ["ofl__mouni"] = "谋逆",
  [":ofl__mouni"] = "回合开始时，你可以令一名其他角色展示所有手牌，对其依次使用其中所有的【杀】直到该角色进入濒死状态。"..
  "若以此法使用的【杀】均未造成伤害，你结束此回合。",

  ["#ofl__mouni-choose"] = "谋逆：令一名角色展示所有手牌，对其使用其中所有【杀】！",
}

mouni:addEffect(fk.TurnStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(mouni.name) and
      table.find(player.room:getOtherPlayers(player, false), function (p)
        return not p:isKongcheng()
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return not p:isKongcheng()
    end)
    local to = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#ofl__mouni-choose",
      skill_name = mouni.name,
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local ids = table.filter(to:getCardIds("h"), function(id)
      return Fk:getCardById(id).trueName == "slash"
    end)
    to:showCards(to:getCardIds("h"))
    if player.dead or to.dead or #ids == 0 then return end
    local yes = false
    for _, id in ipairs(ids) do
      if player.dead or to.dead then return end
      if table.contains(to:getCardIds("h"), id) then
        local card = Fk:getCardById(id)
        if player:canUseTo(card, to, { bypass_times = true, bypass_distances = true }) then
          local use = {
            from = player,
            tos = {to},
            card = card,
            extraUse = true,
          }
          use.extra_data = use.extra_data or {}
          use.extra_data.ofl__mouni_use = player.id
          room:useCard(use)
          if use and use.damageDealt then
            yes = true
          end
          if use.extra_data.ofl__mouni_dying then
            break
          end
        end
      end
    end
    if not yes and not player.dead then
      room:endTurn()
    end
  end,
})

mouni:addEffect(fk.EnterDying, {
  can_refresh = function (self, event, target, player, data)
    if data.damage and data.damage.card then
      local e = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      if e then
        local use = e.data
        return use.extra_data and use.extra_data.ofl__mouni_use == player.id
      end
    end
  end,
  on_refresh = function (self, event, target, player, data)
    local e = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
    if e then
      local use = e.data
      use.extra_data = use.extra_data or {}
      use.extra_data.ofl__mouni_dying = true
    end
  end,
})

return mouni
