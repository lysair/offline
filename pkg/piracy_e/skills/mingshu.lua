local mingshu = fk.CreateSkill({
  name = "ofl__mingshu",
  tags = { Skill.Compulsory },
})

Fk:loadTranslationTable{
  ["ofl__mingshu"] = "命数",
  [":ofl__mingshu"] = "锁定技，当你发动〖登天〗后，若一项的数值达到3或以上，你失去X点体力（X为你当前体力值）。",
}

mingshu:addEffect(fk.AfterSkillEffect, {
  anim_type = "negative",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(mingshu.name) and
      data.skill.name == "ofl__dengtian" and
      table.find({"ofl__dengtian_draw", "ofl__dengtian_maxcards", "ofl__dengtian_damage"}, function (mark)
        return player:getMark(mark) > 2
      end) and
      player.hp > 0
  end,
  on_use = function (self, event, target, player, data)
    player.room:loseHp(player, player.hp, mingshu.name)
  end,
})

return mingshu
