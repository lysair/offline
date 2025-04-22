local yanggu = fk.CreateSkill {
  name = "ofl__yanggu",
  tags = { Skill.Switch },
}

Fk:loadTranslationTable{
  ["ofl__yanggu"] = "佯固",
  [":ofl__yanggu"] = "转换技，阳：当你受到伤害后，你可以回复1点体力；阴：你可以将一张手牌当【声东击西】使用。",

  ["#ofl__yanggu-yang"] = "佯固：是否回复1点体力？",
  ["#ofl__yanggu-yin"] = "佯固：你可以将一张手牌当【声东击西】使用",
}

yanggu:addEffect(fk.Damaged, {
  anim_type = "switch",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(yanggu.name) then
      if player:getSwitchSkillState(yanggu.name, false) == fk.SwitchYang then
        return player:isWounded()
      else
        return #player:getHandlyIds() > 0
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if player:getSwitchSkillState(yanggu.name, false) == fk.SwitchYang then
      return room:askToSkillInvoke(player, {
        skill_name = "ofl__yanggu",
        prompt = "#ofl__yanggu-yang"
      })
    else
      local use = room:askToUseVirtualCard(player, {
        name = "diversion",
        skill_name = yanggu.name,
        prompt = "#ofl__yanggu-yin",
        cancelable = true,
        card_filter = {
          n = 1,
          cards = player:getHandlyIds(),
        },
        skip = true,
      })
      if use then
        event:setCostData(self, {extra_data = use})
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player:getSwitchSkillState(yanggu.name, true) == fk.SwitchYang then
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skill_name = yanggu.name,
      }
    else
      room:useCard(event:getCostData(self).extra_data)
    end
  end,
})

return yanggu
