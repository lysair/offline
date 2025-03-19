local yanggu = fk.CreateSkill {
  name = "ofl__yanggu"
}

Fk:loadTranslationTable{
  ['ofl__yanggu'] = '佯固',
  ['#ofl__yanggu-yin'] = '佯固：你可以将一张手牌当【声东击西】使用',
  ['#ofl__yanggu_trigger'] = '佯固',
  ['#ofl__yanggu-yang'] = '佯固：是否回复1点体力？',
  [':ofl__yanggu'] = '转换技，阳：当你受到伤害后，你可以回复1点体力；阴：你可以将一张手牌当【声东击西】使用。',
}

yanggu:addEffect('viewas', {
  switch_skill_name = "ofl__yanggu",
  anim_type = "switch",
  pattern = "diversion",
  prompt = "#ofl__yanggu-yin",
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(player:getHandlyIds(true), to_select)
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("diversion")
    card.skillName = skill.name
    card:addSubcard(cards[1])
    return card
  end,
  enabled_at_play = function (skill, player)
    return player:getSwitchSkillState(skill.name, false) == fk.SwitchYin
  end,
  enabled_at_response = function (skill, player, response)
    return not response and player:getSwitchSkillState(skill.name, false) == fk.SwitchYin
  end,
})

yanggu:addEffect(fk.Damaged, {
  anim_type = "switch",
  main_skill = yanggu,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yanggu) and player:getSwitchSkillState("ofl__yanggu", false) == fk.SwitchYang
      and player:isWounded()
  end,
  on_cost = function (skill, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = "ofl__yanggu",
      prompt = "#ofl__yanggu-yang"
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(target, MarkEnum.SwithSkillPreName.."ofl__yanggu", player:getSwitchSkillState("ofl__yanggu", true))
    player:addSkillUseHistory("ofl__yanggu")
    room:recover{
      who = player,
      num = 1,
      recoverBy = player,
      skill_name = "ofl__yanggu",
    }
  end,
})

return yanggu
