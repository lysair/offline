local lianhuan = fk.CreateSkill {
  name = "ofl_mou__lianhuan",
}

Fk:loadTranslationTable{
  ["ofl_mou__lianhuan"] = "连环",
  [":ofl_mou__lianhuan"] = "出牌阶段，你可以将一张♣手牌当【铁索连环】使用或重铸；当你使用【铁索连环】指定一名未横置的角色为目标后，"..
  "你可以弃置其一张牌。",

  ["#ofl_mou__lianhuan"] = "连环：你可以将一张♣手牌当【铁索连环】使用或重铸",
  ["#ofl_mou__lianhuan-invoke"] = "连环：是否弃置 %dest 一张牌？",
  ["#ofl_mou__lianhuan-discard"] = "连环：弃置 %dest 一张牌",

  ["$ofl_mou__lianhuan1"] = "大小战船，皆连锁之，则风浪难覆。",
  ["$ofl_mou__lianhuan2"] = "铁索系舟，遇火难逃。",
}

lianhuan:addEffect("active", {
  mute = true,
  prompt = "#ofl_mou__lianhuan",
  card_num = 1,
  min_target_num = 0,
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).suit == Card.Club and table.contains(player:getHandlyIds(), to_select)
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected_cards == 1 then
      local card = Fk:cloneCard("iron_chain")
      card:addSubcard(selected_cards[1])
      card.skillName = lianhuan.name
      return player:canUse(card) and card.skill:targetFilter(player, to_select, selected, selected_cards, card)
    end
  end,
  feasible = function (self, player, selected, selected_cards)
    if #selected_cards == 1 then
      if #selected == 0 then
        return table.contains(player:getCardIds("h"), selected_cards[1])
      else
        local card = Fk:cloneCard("iron_chain")
        card:addSubcard(selected_cards[1])
        card.skillName = lianhuan.name
        return card.skill:feasible(player, selected, {}, card)
      end
    end
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    player:broadcastSkillInvoke(lianhuan.name)
    if #effect.tos == 0 then
      room:notifySkillInvoked(player, lianhuan.name, "drawcard")
      room:recastCard(effect.cards, player, lianhuan.name)
    else
      room:notifySkillInvoked(player, lianhuan.name, "control")
      room:sortByAction(effect.tos)
      room:useVirtualCard("iron_chain", effect.cards, player, effect.tos, lianhuan.name)
    end
  end,
})

lianhuan:addEffect(fk.TargetSpecified, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(lianhuan.name) and data.card.trueName == "iron_chain" and
      not data.to.chained and not data.to:isNude() and not data.to.dead
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if data.to == player and
      not table.find(player:getCardIds("he"), function (id)
        return not player:prohibitDiscard(id)
      end) then
      room:askToCards(player, {
        min_num = 1,
        max_num = 1,
        include_equip = false,
        skill_name = lianhuan.name,
        pattern = "false",
        prompt = "#ofl_mou__lianhuan-invoke::"..data.to.id,
        cancelable = true,
      })
    else
      if room:askToSkillInvoke(player, {
        skill_name = lianhuan.name,
        prompt = "#ofl_mou__lianhuan-invoke::"..data.to.id,
      }) then
        event:setCostData(self, {tos = {data.to}})
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if data.to == player then
      room:askToDiscard(player, {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        skill_name = lianhuan.name,
        prompt = "#ofl_mou__lianhuan-discard::"..data.to.id,
        cancelable = false,
      })
    else
      local id = room:askToChooseCard(player, {
        target = data.to,
        flag = "he",
        skill_name = lianhuan.name,
        prompt = "#ofl_mou__lianhuan-discard::"..data.to.id,
      })
      room:throwCard(id, lianhuan.name, data.to, player)
    end
  end,
})

return lianhuan
