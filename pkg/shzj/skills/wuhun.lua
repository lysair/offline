local wuhun = fk.CreateSkill {
  name = "shzj_yiling__wuhun",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable {
  ["shzj_yiling__wuhun"] = "武魂",
  [":shzj_yiling__wuhun"] = "锁定技，当你受到1点伤害后，伤害来源获得1枚“梦魇”；当你死亡时，你令凶手或“梦魇”最多的一名其他角色判定，"..
  "若不为【桃】，其死亡。",

  ["#shzj_yiling__wuhun-choose"] = "武魂：选择一名角色进行判定",
}

wuhun:addLoseEffect(function (self, player)
  local room = player.room
  for _, p in ipairs(room.alive_players) do
    room:setPlayerMark(p, "@nightmare", 0)
  end
end)

wuhun:addEffect(fk.Damaged, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(wuhun.name) and
      data.from and not data.from.dead
  end,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(data.from, "@nightmare", data.damage)
  end,
})

wuhun:addEffect(fk.Death, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return
      target == player and
      player:hasSkill(wuhun.name, false, true) and
      (
        (data.killer and data.killer:isAlive()) or
        table.find(player.room.alive_players, function(p) return p ~= player and p:getMark("@nightmare") > 0 end)
      )
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    local maxNightmare = 1
    table.forEach(room:getOtherPlayers(player, false), function(p)
      local nightmareMark = p:getMark("@nightmare")
      if nightmareMark > maxNightmare then
        maxNightmare = nightmareMark
        targets = {}
      end

      if nightmareMark == maxNightmare then
        table.insert(targets, p)
      end
    end)
    if data.killer and not data.killer.dead then
      table.insertIfNeed(targets, data.killer)
    end

    if #targets == 0 then
      return false
    end

    if #targets > 1 then
      targets = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 1,
        targets = targets,
        skill_name = wuhun.name,
        prompt = "#shzj_yiling__wuhun-choose",
        cancelable = false,
      })
    end
    local to = targets[1]
    local judge = {
      who = to,
      reason = wuhun.name,
      pattern = "peach",
    }
    room:judge(judge)
    if judge:matchPattern() or to.dead then return end
    room:killPlayer{
      who = to,
      killer = player,
    }
  end,
})

return wuhun
