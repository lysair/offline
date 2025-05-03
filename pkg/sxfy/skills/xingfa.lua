local xingfa = fk.CreateSkill {
  name = "sxfy__xingfa",
}

Fk:loadTranslationTable{
  ["sxfy__xingfa"] = "兴伐",
  [":sxfy__xingfa"] = "准备阶段，若你的手牌数不小于体力值，你可以对一名其他角色造成1点伤害。",

  ["#sxfy__xingfa-choose"] = "兴伐：你可以对一名其他角色造成1点伤害",
}

xingfa:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xingfa.name) and player.phase == Player.Start and
      player:getHandcardNum() >= player.hp and #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player, false),
      skill_name = xingfa.name,
      prompt = "#sxfy__xingfa-choose",
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:damage{
      from = player,
      to = event:getCostData(self).tos[1],
      damage = 1,
      skillName = xingfa.name,
    }
  end,
})

return xingfa
