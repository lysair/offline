local shice = fk.CreateSkill {
  name = "ofl__shice",
  tags = { Skill.Switch },
}

Fk:loadTranslationTable{
  ["ofl__shice"] = "势策",
  [":ofl__shice"] = "转换技，①当你受到属性伤害时，若你的技能数不大于伤害来源，你可以防止此伤害并视为使用一张【火攻】；②当你不因此技能使用牌"..
  "指定唯一目标后，你可以令其弃置装备区任意张牌，然后此牌额外结算X次（X为其装备区的牌数）。",

  ["#ofl__shice-yang"] = "势策：你可以防止你受到的伤害，然后视为使用一张【火攻】",
  ["#ofl__shice-yin"] = "势策：是否令 %dest 弃置任意张装备并使%arg额外结算？",
  ["#ol__xiaoxi-fire_attack"] = "势策：你可以视为使用一张【火攻】",
  ["#ofl__shice-discard"] = "势策：弃置任意张装备，此%arg将额外结算你装备区牌数的次数！",
}

shice:addEffect(fk.DamageInflicted, {
  anim_type = "switch",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shice.name) and
      player:getSwitchSkillState(shice.name, false) == fk.SwitchYang and
      data.damageType ~= fk.NormalDamage and data.from and
      #player:getSkillNameList() <= #data.from:getSkillNameList()
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = shice.name,
      prompt = "#ofl__shice-yang",
    })
  end,
  on_use = function(self, event, target, player, data)
    data:preventDamage()
    player.room:askToUseVirtualCard(player, {
      name = "fire_attack",
      skill_name = shice.name,
      prompt = "#ol__xiaoxi-fire_attack",
      cancelable = true,
    })
  end,
})

shice:addEffect(fk.TargetSpecified, {
  anim_type = "switch",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shice.name) and
      player:getSwitchSkillState(shice.name, false) == fk.SwitchYin and
      data:isOnlyTarget(data.to) and not table.contains(data.card.skillNames, shice.name)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = shice.name,
      prompt = "#ofl__shice-yin::"..data.to.id..":"..data.card:toLogString(),
    }) then
      event:setCostData(self, {tos = {data.to}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:askToDiscard(data.to, {
      min_num = 1,
      max_num = 10,
      include_equip = true,
      skill_name = shice.name,
      cancelable = true,
      pattern = ".|.|.|equip",
      prompt = "#ofl__shice-discard:::"..data.card:toLogString(),
    })
    local n = #data.to:getCardIds("e")
    if n > 0 then
      data.use.additionalEffect = (data.use.additionalEffect or 0) + n
    end
  end,
})

return shice
