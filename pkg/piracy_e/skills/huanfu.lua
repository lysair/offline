local huanfu = fk.CreateSkill{
  name = "ofl__huanfu",
}

Fk:loadTranslationTable{
  ["ofl__huanfu"] = "宦浮",
  [":ofl__huanfu"] = "当你使用【杀】指定目标后或成为【杀】的目标后，你可以弃置至多你的体力上限张牌，然后摸2X张牌，若如此做，"..
  "此【杀】对目标角色造成的伤害改为X（X为你弃置的牌数）。",

  ["#ofl__huanfu-invoke"] = "宦浮：弃置至多%arg张牌，摸两倍的牌，此【杀】对 %dest 的伤害改为弃牌数",

  ["$ofl__huanfu1"] = "何日能脱宦海去，临江饱看碧水流。",
  ["$ofl__huanfu2"] = "十年宦海漂泊客，一声云雁一襟秋。",
}

local huanfu_spec = {
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = room:askToDiscard(player, {
      min_num = 1,
      max_num = player.maxHp,
      include_equip = true,
      skill_name = huanfu.name,
      prompt = "#ofl__huanfu-invoke::"..data.to.id..":"..player.maxHp,
      cancelable = true,
      skip = true,
    })
    if #cards > 0 then
      event:setCostData(self, {cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local cards = event:getCostData(self).cards
    data.extra_data = data.extra_data or {}
    data.extra_data.ofl__huanfu = data.extra_data.ofl__huanfu or {}
    data.extra_data.ofl__huanfu[data.to] = #cards
    player.room:throwCard(cards, huanfu.name, player, player)
    if not player.dead then
      player:drawCards(2 * #cards, huanfu.name)
    end
  end,
}

huanfu:addEffect(fk.TargetSpecified, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(huanfu.name) and data.card.trueName == "slash" and
      not player:isNude() and data.firstTarget
  end,
  on_cost = huanfu_spec.on_cost,
  on_use = huanfu_spec.on_use,
})
huanfu:addEffect(fk.TargetConfirmed, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(huanfu.name) and data.card.trueName == "slash" and
      not player:isNude()
  end,
  on_cost = huanfu_spec.on_cost,
  on_use = huanfu_spec.on_use,
})

huanfu:addEffect(fk.DamageCaused, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if data.card and data.card.trueName == "slash" and player.room.logic:damageByCardEffect() then
      local use_event = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      if use_event then
        local use = use_event.data
        if use.extra_data and use.extra_data.ofl__huanfu and use.extra_data.ofl__huanfu[data.to] then
          event:setCostData(self, {choice = use.extra_data.ofl__huanfu[data.to]})
          return true
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    data:changeDamage(event:getCostData(self).choice - data.damage)
  end,
})

return huanfu
