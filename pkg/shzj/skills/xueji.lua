local xueji = fk.CreateSkill{
  name = "shzj_guansuo__xueji",
}

Fk:loadTranslationTable{
  ["shzj_guansuo__xueji"] = "血祭",
  [":shzj_guansuo__xueji"] = "出牌阶段限一次，你可以对至多X名角色各造成1点火焰伤害（X为你已损失体力值，至少为1）。",

  ["#shzj_guansuo__xueji"] = "血祭：对至多%arg名角色各造成1点火焰伤害！",

  ["$shzj_guansuo__xueji1"] = "过年又添一岁，旧账何日两清！",
  ["$shzj_guansuo__xueji2"] = "故地覆雪，啮齿长恨！",
}

xueji:addEffect("active", {
  anim_type = "offensive",
  prompt = function (self, player)
    return "#shzj_guansuo__xueji:::"..math.max(1, player:getLostHp())
  end,
  card_num = 0,
  min_target_num = 1,
  max_target_num = function (self, player)
    return math.max(1, player:getLostHp())
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(xueji.name, Player.HistoryTurn) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected < math.max(1, player:getLostHp())
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local targets = table.simpleClone(effect.tos)
    room:sortByAction(targets)
    for _, p in ipairs(targets) do
      if not p.dead then
        room:damage{
          from = player,
          to = p,
          damage = 1,
          skillName = xueji.name,
          damageType = fk.FireDamage,
        }
      end
    end
  end,
})

return xueji
