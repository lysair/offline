local jiaohu = fk.CreateSkill {
  name = "jiaohu",
  tags = { Skill.AttachedKingdom },
  attached_kingdom = {"shu"},
}

Fk:loadTranslationTable{
  ["jiaohu"] = "骄扈",
  [":jiaohu"] = "蜀势力技，摸牌阶段，你多摸X张牌（X为一号位已损失体力值+1）。",
}

jiaohu:addEffect(fk.DrawNCards, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jiaohu.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    data.n = data.n + 1 + player.room:getPlayerBySeat(1):getLostHp()
  end,
})

return jiaohu
