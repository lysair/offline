local ganran = fk.CreateSkill {
  name = "ganran",
}

Fk:loadTranslationTable{
  ["ganran"] = "感染",
  [":ganran"] = "结束阶段，若你本回合杀死了一名角色且其不为丧尸，用丧尸代替该角色加入游戏，然后你回复所有体力并摸等量张牌。",
}

ganran:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(ganran.name) and player.phase == Player.Finish and
      #player.room.logic:getEventsOfScope(GameEvent.Death, 1, function (e)
        local death = e.data
        return death.killer == player and death.who.general ~= "ofl__zombie"
      end, Player.HistoryTurn) > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local targets = {}
    room.logic:getEventsOfScope(GameEvent.Death, 1, function (e)
      local death = e.data
      if death.killer == player and death.who.general ~= "ofl__zombie" then
        table.insertIfNeed(targets, death.who)
      end
    end, Player.HistoryTurn)
    room:sortByAction(targets)
    room:doIndicate(player, targets)
    local jiaxu = room:getPlayerById(player:getMark("longmu_jiaxu"))
    for _, p in ipairs(targets) do
      if p.dead then
        room:setPlayerProperty(p, "general", "ofl__zombie")
        room:setPlayerProperty(p, "deputyGeneral", "")
        room:setPlayerProperty(p, "kingdom", "qun")
        room:setPlayerProperty(p, "dead", false)
        p._splayer:setDied(false)
        room:setPlayerProperty(p, "dying", false)
        room:setPlayerProperty(p, "maxHp", 4)
        room:setPlayerProperty(p, "hp", 2)
        table.insertIfNeed(room.alive_players, p)
        room:sendLog {
          type = "#Revive",
          from = p.id,
        }
        if jiaxu then
          local role = jiaxu.role
          if jiaxu.role == "lord" then
            role = "loyalist"
          end
          p.role = role
          room:setPlayerProperty(p, "role_shown", jiaxu.role_shown)
          room:setPlayerProperty(p, "role", role)
          room:setPlayerMark(p, "longmu_jiaxu", jiaxu.id)
        end
        room:handleAddLoseSkills(p, "shibian|ganran", nil, false)
        room.logic:trigger(fk.AfterPlayerRevived, p, {
          who = p,
          reason = ganran.name,
        })
      end
    end
    if not player.dead and player:isWounded() then
      local n = player.maxHp - player.hp
      room:recover{
        who = player,
        num = n,
        recoverBy = player,
        skillName = ganran.name,
      }
      if not player.dead then
        player:drawCards(n, ganran.name)
      end
    end
  end,
})

return ganran
