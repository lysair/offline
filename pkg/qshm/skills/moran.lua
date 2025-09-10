local moran = fk.CreateSkill {
  name = "moran",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["moran"] = "默然",
  [":moran"] = "锁定技，当你受到伤害后，你选择1~3的数字，你在所选数字个回合结束后（包括当前回合）摸两倍的牌，在此期间你的所有技能失效。",

  ["#moran-choice"] = "默然：选择1~3的数字，此数量的回合结束后，你摸两倍的牌，在此期间你的所有技能失效！",
  ["@moran"] = "默然",
}

moran:addEffect(fk.Damaged, {
  anim_type = "masochism",
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = room:askToNumber(player, {
      skill_name = moran.name,
      prompt = "#moran-choice",
      min = 1,
      max = 3,
      cancelable = false,
    })
    room:setPlayerMark(player, "@moran", n)
    room:setPlayerMark(player, moran.name, n)
    room:invalidateSkill(player, moran.name)
  end,
})

moran:addEffect(fk.TurnEnd, {
  anim_type = "drawcard",
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    if player:getMark(moran.name) > 0 then
      player.room:removePlayerMark(player, "@moran", 1)
      return player:getMark("@moran") == 0
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:validateSkill(player, moran.name)
    local n = player:getMark(moran.name)
    room:setPlayerMark(player, moran.name, 0)
    player:drawCards(2 * n, moran.name)
  end,
})

moran:addEffect("invalidity", {
  invalidity_func = function (self, from, skill)
    return from:getMark(moran.name) > 0 and table.contains(from:getSkillNameList(), skill.name)
  end,
})

return moran
