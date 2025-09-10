local cuijin = fk.CreateSkill{
  name = "ofl_tx__cuijin",
}

Fk:loadTranslationTable{
  ["ofl_tx__cuijin"] = "催进",
  [":ofl_tx__cuijin"] = "当一名角色使用【杀】时，你可以弃置一张牌，若此【杀】造成伤害且受伤角色不为你，此伤害+1，"..
  "否则你对使用者造成1点伤害。",

  ["#ofl_tx__cuijin-invoke"] = "催进：是否弃置一张牌，对 %dest 发动“催进”？",

  ["$ofl_tx__cuijin1"] = "诸军速行，违者军法论处！",
  ["$ofl_tx__cuijin2"] = "快！贻误军机者，定斩不赦！",
}

cuijin:addEffect(fk.CardUsing, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(cuijin.name) and
      data.card.trueName == "slash" and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local card = room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = cuijin.name,
      skip = true,
      prompt = "#ofl_tx__cuijin-invoke::" .. target.id,
    })
    if #card > 0 then
      event:setCostData(self, { cards = card, tos = {target} })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    data.extra_data = data.extra_data or {}
    data.extra_data.ofl_tx__cuijin = data.extra_data.ofl_tx__cuijin or {}
    table.insertIfNeed(data.extra_data.ofl_tx__cuijin, player)
    player.room:throwCard(event:getCostData(self).cards, cuijin.name, player, player)
  end,
})

cuijin:addEffect(fk.DamageCaused, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    if target == player and data.card and data.card.trueName == "slash" then
      local use_event = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      if use_event then
        local use = use_event.data
        return use.extra_data and use.extra_data.ofl_tx__cuijin and not table.contains(use.extra_data.ofl_tx__cuijin, data.to)
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    data:changeDamage(1)
  end,
})

cuijin:addEffect(fk.CardUseFinished, {
  anim_type = "offensive",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if not player.dead and not target.dead and
      data.extra_data and data.extra_data.ofl_tx__cuijin and
      table.contains(data.extra_data.ofl_tx__cuijin, player) then
        if not data.damageDealt then
          return true
        else
          for k, _ in pairs(data.damageDealt) do
            if k ~= player then
              return false
            end
          end
          return true
        end
      end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player, { target })
    room:damage{
      from = player,
      to = target,
      damage = 1,
      skillName = cuijin.name,
    }
  end,
})

return cuijin
