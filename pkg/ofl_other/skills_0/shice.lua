local shice = fk.CreateSkill {
  name = "ofl__shice"
}

Fk:loadTranslationTable{
  ['ofl__shice'] = '势策',
  ['#ofl__shice-yang'] = '势策：你可以防止你受到的伤害，视为使用一张【火攻】',
  ['#ofl__shice-yin'] = '势策：是否令 %dest 弃置任意张装备并使%arg额外结算？',
  ['#ofl__shice-discard'] = '势策：弃置任意张装备，然后此%arg将额外结算你装备区牌数的次数！',
  [':ofl__shice'] = '转换技，①当你受到属性伤害时，若你的技能数不大于伤害来源，你可以防止此伤害并视为使用一张【火攻】；②当你不因此技能使用牌指定唯一目标后，你可以令其弃置装备区任意张牌，然后此牌额外结算X次（X为其装备区的牌数）。',
}

shice:addEffect(fk.DamageInflicted, {
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(shice.name) then
      if player:getSwitchSkillState(shice.name, false) == fk.SwitchYang and
        data.damageType ~= fk.NormalDamage and
        data.from then
        local getSkills = function (p)
          local skills = {}
          for _, s in ipairs(p.player_skills) do
            if s:isPlayerSkill(p) and s.visible then
              table.insertIfNeed(skills, s.name)
            end
          end
          return skills
        end
        return #getSkills(player) <= #getSkills(data.from)
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local use = U.askForUseVirtualCard(room, player, "fire_attack", nil, shice.name,
      "#ofl__shice-yang", true, false, false, false, nil, true)
    if use then
      event:setCostData(self, use)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:useCard(event:getCostData(self))
    return true
  end,
})

shice:addEffect(fk.TargetSpecified, {
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(shice.name) then
      if player:getSwitchSkillState(shice.name, false) == fk.SwitchYin and
        #TargetGroup:getRealTargets(data.tos) == 1 and not table.contains(data.card.skillNames, shice.name) then
        local to = player.room:getPlayerById(data.to)
        return not to.dead and #to:getCardIds("e") > 0
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = shice.name,
      prompt = "#ofl__shice-yin::"..data.to..":"..data.card:toLogString()
    }) then
      event:setCostData(self, {tos = {data.to}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(data.to)
    room:askToDiscard(to, {
      min_num = 1,
      max_num = 10,
      include_equip = true,
      skill_name = shice.name,
      cancelable = true,
      pattern = ".|.|.|equip",
      prompt = "#ofl__shice-discard:::"..data.card:toLogString()
    })
    local n = #to:getCardIds("e")
    if n > 0 then
      data.additionalEffect = (data.additionalEffect or 0) + n
    end
  end,
})

return shice
