
local mouduan = fk.CreateSkill{
  name = "ofl_tx__mouduan",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_tx__mouduan"] = "谋断",
  [":ofl_tx__mouduan"] = "锁定技，当你使用锦囊牌指定敌方角色为目标时，其需选择一个非锁定技失效，直到其受到伤害后或其回合结束。",

  ["#ofl_tx__mouduan-choice"] = "谋断：你需选择一个技能失效直到你受到伤害或回合结束",
}

mouduan:addEffect(fk.TargetSpecifying, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(mouduan.name) and
      data.card.type == Card.TypeTrick and data.to:isEnemy(player)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local skills = {}
    for _, s in ipairs(data.to:getSkillNameList()) do
      if data.to:hasSkill(s) and not Fk.skills[s]:hasTag(Skill.Compulsory) then
        table.insertIfNeed(skills, s)
      end
    end
    if #skills == 0 then return end
    local choice = skills[1]
    if #skills > 1 then
      choice = room:askToCustomDialog(data.to, {
        skill_name = mouduan.name,
        qml_path = "packages/utility/qml/ChooseSkillBox.qml",
        extra_data = { skills, 1, 1, "#ofl_tx__mouduan-choice" },
      })
      if #choice == 0 then
        choice = skills[1]
      else
        choice = choice[1]
      end
    end
    room:sendLog{
      type = "#ofl__podai",
      from = player.id,
      to = { data.to.id },
      arg = choice,
      toast = true,
    }
    room:addTableMarkIfNeed(data.to, mouduan.name, choice)
  end,
})

mouduan:addEffect(fk.Damaged, {
  late_refresh = true,
  can_refresh = function (self, event, target, player, data)
    return target == player
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(player, mouduan.name, 0)
  end,
})

mouduan:addEffect(fk.TurnEnd, {
  late_refresh = true,
  can_refresh = function (self, event, target, player, data)
    return target == player
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(player, mouduan.name, 0)
  end,
})

mouduan:addEffect("invalidity", {
  invalidity_func = function (self, from, skill)
    return table.contains(from:getTableMark(mouduan.name), skill:getSkeleton().name)
  end,
})

return mouduan
