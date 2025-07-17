
local silve = fk.CreateSkill{
  name = "silve",
  derived_piles = "silve",
}

Fk:loadTranslationTable{
  ["silve"] = "肆掠",
  [":silve"] = "摸牌阶段开始时，你可以改为获得任意名角色合计至多两张牌，然后将等量的牌置于武将牌上，称为“掠”。",

  ["#silve-choose"] = "肆掠：获得任意名角色合计至多两张牌，然后将等量牌置为“掠”",
  ["#silve-ask"] = "肆掠：请将%arg张牌置为“掠”",
}

silve:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(silve.name) and player.phase == Player.Draw and
      table.find(player.room:getOtherPlayers(player, false), function(p)
        return not p:isNude()
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function(p)
      return not p:isNude()
    end)
    local tos = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 2,
      prompt = "#silve-choose",
      skill_name = silve.name,
      cancelable = true,
    })
    if #tos > 0 then
      room:sortByAction(tos)
      event:setCostData(self, { tos = tos })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data.phase_end = true
    local tos = event:getCostData(self).tos
    local n = 0
    for _, to in ipairs(tos) do
      if player.dead then return end
      if not (to.dead or to:isNude()) then
        local cards = room:askToChooseCards(player, {
          target = to,
          min = 1,
          max = #tos == 2 and 1 or 2,
          flag = "he",
          skill_name = silve.name,
        })
        n = n + #cards
        room:obtainCard(player, cards, false, fk.ReasonPrey, player, silve.name)
      end
    end
    if not player.dead and not player:isNude() then
      local cards = room:askToCards(player, {
        min_num = n,
        max_num = n,
        include_equip = true,
        skill_name = silve.name,
        prompt = "#silve-ask:::"..n,
        cancelable = false,
      })
      player:addToPile(silve.name, cards, true, silve.name, player)
    end
  end,
})

return silve
