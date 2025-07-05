local yanggu = fk.CreateSkill {
  name = "ofl__yanggu",
  tags = { Skill.Switch },
}

Fk:loadTranslationTable{
  ["ofl__yanggu"] = "佯固",
  [":ofl__yanggu"] = "转换技，阳：当你受到伤害后，你可以回复1点体力；阴：你可以将一张手牌当<a href=':diversion'>【声东击西】</a>使用。",

  ["#ofl__yanggu-yang"] = "佯固：是否回复1点体力？",
  ["#ofl__yanggu-yin"] = "佯固：你可以将一张手牌当【声东击西】使用",
}

yanggu:addEffect("viewas", {
  anim_type = "switch",
  pattern = "diversion",
  prompt = "#ofl__yanggu-yin",
  card_filter = function (self, player, to_select, selected)
    return #selected == 0 and table.contains(player:getHandlyIds(), to_select)
  end,
  view_as = function (self, player, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("diversion")
    card.skillName = yanggu.name
    card:addSubcards(cards)
    return card
  end,
  enabled_at_play = function (self, player)
    return player:getSwitchSkillState(yanggu.name, false) == fk.SwitchYin
  end,
  enabled_at_response = function (self, player, response)
    return not response and player:getSwitchSkillState(yanggu.name, false) == fk.SwitchYin
  end,
})

yanggu:addEffect(fk.Damaged, {
  anim_type = "switch",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yanggu.name) and
      player:getSwitchSkillState(yanggu.name, false) == fk.SwitchYang and player:isWounded()
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = yanggu.name,
      prompt = "#ofl__yanggu-yang"
    })
  end,
  on_use = function(self, event, target, player, data)
    player.room:recover{
      who = player,
      num = 1,
      recoverBy = player,
      skill_name = yanggu.name,
    }
  end,
})

return yanggu
