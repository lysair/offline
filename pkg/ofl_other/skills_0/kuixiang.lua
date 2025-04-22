local kuixiang = fk.CreateSkill {
  name = "ofl__kuixiang"
}

Fk:loadTranslationTable{
  ['ofl__kuixiang'] = '溃降',
  ['#ofl__kuixiang-invoke'] = '溃降：是否对 %dest 造成1点伤害？若杀死其你摸三张牌',
  ['#ofl__kuixiang_delay'] = '溃降',
  [':ofl__kuixiang'] = '每名角色限一次，其他角色脱离濒死状态时，你可以对其造成1点伤害，若因此杀死该角色，你摸三张牌。',
}

kuixiang:addEffect(fk.AfterDying, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(kuixiang.name) and not target.dead and
      not table.contains(player:getTableMark(kuixiang.name), target.id)
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askToSkillInvoke(player, {
      skill_name = kuixiang.name,
      prompt = "#ofl__kuixiang-invoke::" .. target.id
    }) then
      event:setCostData(self, {tos = {target.id}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addTableMark(player, kuixiang.name, target.id)
    room:damage{
      from = player,
      to = target,
      damage = 1,
      skillName = kuixiang.name,
    }
  end,
})

kuixiang:addEffect(fk.Death, {
  name = "#ofl__kuixiang_delay",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return not player.dead and target.data.damage and target.data.damage.from == player and
      target.data.damage.skillName == "ofl__kuixiang"
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player:drawCards(3, kuixiang.name)
  end,
})

return kuixiang
