local yuanjue = fk.CreateSkill {
  name = "yuanjue",
  tags = { Skill.Switch },
}

Fk:loadTranslationTable{
  ["yuanjue"] = "援绝",
  [":yuanjue"] = "转换技，你可以跳过摸牌阶段，直到你下次发动此技能或你死亡：阳：所有角色的基本牌视为无次数限制的【杀】；"..
  "阴：所有角色与你互相计算距离视为1，你视为拥有技能〖同忾〗。",

  ["#yuanjue-invoke"] = "援绝：是否跳过摸牌阶段，切换“援绝”状态？",
  ["@yuanjue"] = "援绝",
}

yuanjue:addEffect(fk.EventPhaseChanging, {
  anim_type = "switch",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(yuanjue.name) and data.phase == Player.Draw and
      not data.skipped
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = yuanjue.name,
      prompt = "#yuanjue-invoke",
    })
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    data.skipped = true
    local status = player:getSwitchSkillState(yuanjue.name, true, true)
    room:setPlayerMark(player, "@yuanjue", status)
    if status == "yin" then
      room:handleAddLoseSkills(player, "tongkai")
    else
      room:handleAddLoseSkills(player, "-tongkai")
    end
  end,
})

yuanjue:addEffect(fk.PreCardUse, {
  can_refresh = function (self, event, target, player, data)
    return target == player and table.contains(data.card.skillNames, yuanjue.name)
  end,
  on_refresh = function (self, event, target, player, data)
    data.extraUse = true
  end,
})

yuanjue:addEffect("filter", {
  mute = true,
  card_filter = function(self, to_select, player)
    return table.find(Fk:currentRoom().alive_players, function (p)
      return p:getMark("@yuanjue") == "yang"
    end) and
      to_select.type == Card.TypeBasic and table.contains(player:getCardIds("h"), to_select.id)
  end,
  view_as = function(self, player, card)
    local c = Fk:cloneCard("slash", card.suit, card.number)
    c.skillName = yuanjue.name
    return c
  end,
})

yuanjue:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    return card and table.contains(card.skillNames, yuanjue.name)
  end,
})

yuanjue:addEffect("distance", {
  fixed_func = function(self, from, to)
    if from:getMark("@yuanjue") == "yin" or to:getMark("@yuanjue") == "yin" then
      return 1
    end
  end,
})

yuanjue:addLoseEffect(function (self, player, is_death)
  if is_death then
    player.room:handleAddLoseSkills(player, "-tongkai")
  end
end)

return yuanjue
