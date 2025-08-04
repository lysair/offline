local jingju = fk.CreateSkill {
  name = "ofl__jingju",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl__jingju"] = "旌聚",
  [":ofl__jingju"] = "锁定技，你的摸牌阶段摸牌数、攻击范围、出牌阶段使用【杀】次数为X（X为场上魏势力角色数，至多为5）。",
}

jingju:addEffect(fk.DrawNCards, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(jingju.name)
  end,
  on_use = function (self, event, target, player, data)
    data.n = math.min(5, #table.filter(player.room.alive_players, function (p)
      return p.kingdom == "wei"
    end))
  end,
})

jingju:addEffect("atkrange", {
  final_func = function (self, player)
    if player:hasSkill(jingju.name) then
      return math.min(5, #table.filter(Fk:currentRoom().alive_players, function (p)
        return p.kingdom == "wei"
      end))
    end
  end,
})

jingju:addEffect("targetmod", {
  residue_func = function (self, player, skill, scope, card, to)
    if player:hasSkill(jingju.name) and card and card.trueName == "slash" then
      return math.min(6, #table.filter(Fk:currentRoom().alive_players, function (p)
        return p.kingdom == "wei"
      end)) - 1
    end
  end,
})

return jingju
