local yizheng = fk.CreateSkill {
  name = "sxfy__yizheng",
}

Fk:loadTranslationTable{
  ["sxfy__yizheng"] = "义争",
  [":sxfy__yizheng"] = "准备阶段，你可以与一名体力值不小于你的角色拼点，赢的角色对没赢的角色造成1点伤害。",

  ["#sxfy__yizheng-choose"] = "义争：与一名体力值不小于你的角色拼点，赢者对对方造成1点伤害",
}

yizheng:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player == target and player:hasSkill(yizheng.name) and player.phase == Player.Start and
      table.find(player.room.alive_players, function (p)
        return p.hp >= player.hp and player:canPindian(p)
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function (p)
      return p.hp >= player.hp and player:canPindian(p)
    end)
    local to = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#sxfy__yizheng-choose",
      skill_name = yizheng.name,
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local pindian = player:pindian({to}, yizheng.name)
    local winner = pindian.results[to].winner
    if winner and not winner.dead then
      local loser = (winner == player) and to or player
      if not loser.dead then
        room:damage{
          from = winner,
          to = loser,
          damage = 1,
          skillName = yizheng.name,
        }
      end
    end
  end,
})

return yizheng
