local xianxiang = fk.CreateSkill {
  name = "ofl__xianxiang",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl__xianxiang"] = "献降",
  [":ofl__xianxiang"] = "锁定技，当你杀死一名角色时，你令一名其他角色获得死亡角色区域内的所有牌。",

  ["#ofl__xianxiang-invoke"] = "献降：令一名其他角色获得 %dest 区域内所有牌",
}

xianxiang:addEffect(fk.Death, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(xianxiang.name) and data.killer == player and
      not target:isAllNude() and #player.room:getOtherPlayers(player, false) > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      targets = room:getOtherPlayers(player, false),
      min_num = 1,
      max_num = 1,
      prompt = "#ofl__xianxiang-invoke::" .. target.id,
      skill_name = xianxiang.name,
      cancelable = false,
    })[1]
    room:moveCardTo(target:getCardIds("hej"), Card.PlayerHand, to, fk.ReasonJustMove, xianxiang.name, nil, false, to)
  end,
})

return xianxiang
