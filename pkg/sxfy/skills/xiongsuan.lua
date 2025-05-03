local xiongsuan = fk.CreateSkill {
  name = "sxfy__xiongsuan",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["sxfy__xiongsuan"] = "凶算",
  [":sxfy__xiongsuan"] = "锁定技，准备阶段，若没有角色体力值大于你，你须对至少一名体力值等于你的角色各造成1点伤害。",

  ["#sxfy__xiongsuan-invoke"] = "凶算：对任意名体力值等于你的角色造成1点伤害",
}

xiongsuan:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xiongsuan.name) and player.phase == Player.Start and
      table.every(player.room.alive_players, function (p)
        return p.hp <= player.hp
      end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function (p)
      return p.hp == player.hp
    end)
    local tos = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 10,
      targets = targets,
      skill_name = xiongsuan.name,
      prompt = "#sxfy__xiongsuan-invoke",
      cancelable = false,
    })
    room:sortByAction(tos)
    for _, p in ipairs(tos) do
      if not p.dead then
        room:damage{
          from = player,
          to = p,
          damage = 1,
          skillName = xiongsuan.name,
        }
      end
    end
  end,
})

return xiongsuan
