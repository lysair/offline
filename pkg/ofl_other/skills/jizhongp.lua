local jizhongp = fk.CreateSkill {
  name = "jizhongp"
}

Fk:loadTranslationTable{
  ['jizhongp'] = '集众',
  [':jizhongp'] = '锁定技，起义军摸牌阶段额外摸一张牌，计算与除其以外的角色距离-1。',
}

jizhongp:addEffect(fk.DrawNCards, {
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(jizhongp) and IsInsurrectionary(target)
  end,
  on_use = function(self, event, target, player, data)
    data.n = data.n + 1
  end,
})

jizhongp:addEffect('distance', {
  name = "#jizhongp_distance",
  main_skill = jizhongp,
  frequency = Skill.Compulsory,
  correct_func = function(self, from, to)
    if IsInsurrectionary(from) then
      return -#table.filter(Fk:currentRoom().alive_players, function (p)
        return p:hasSkill(jizhongp)
      end)
    end
  end,
})

return jizhongp
