local juluan = fk.CreateSkill {
  name = "juluan"
}

Fk:loadTranslationTable{
  ['juluan'] = '聚乱',
  ['#juluan-choose'] = '聚乱：你可以令至多两名角色选择成为起义军或你弃置其一张手牌',
  ['#juluan-ask'] = '聚乱：点“确定”加入起义军（起义军技能点击左上角查看），或点“取消” %src 弃置你一张手牌！',
  ['#juluan-discard'] = '聚乱：弃置 %dest 一张手牌',
  [':juluan'] = '锁定技，游戏开始时，你获得起义军标记，然后令至多两名不为一号位且非起义军角色依次选择一项：1.获得起义军标记；2.你弃置其一张手牌。当你每回合第二次造成伤害或受到伤害时，此伤害+1。',
}

juluan:addEffect(fk.GameStart, {
  can_trigger = function(self, event, target, player)
    return player:hasSkill(juluan.name) and true
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    if not IsInsurrectionary(player) then
      JoinInsurrectionary(player)
      room:handleAddLoseSkills(player, "insurrectionary&|-insurrectionary&", nil, false, true)
    end
    local targets = table.filter(room.alive_players, function (p)
      return p.seat ~= 1 and not IsInsurrectionary(p)
    end)
    if #targets == 0 then return end
    local tos = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 2,
      prompt = "#juluan-choose",
      skill_name = juluan.name,
      cancelable = true,
    })
    if #tos > 0 then
      room:sortPlayersByAction(tos)
      for _, p in ipairs(tos) do
        if not p.dead then
          if p:isKongcheng() or player.dead or room:askToSkillInvoke(p, {
            skill_name = juluan.name,
            prompt = "#juluan-ask:"..player.id
          }) then
            JoinInsurrectionary(p)
          else
            local card = room:askToChooseCard(player, {
              target = p,
              flag = "h",
              skill_name = juluan.name,
              prompt = "#juluan-discard::"..p.id
            })
            room:throwCard(card, juluan.name, p, player)
          end
        end
      end
    end
  end,
})

juluan:addEffect(fk.DamageCaused, {
  can_trigger = function(self, event, target, player)
    return player:hasSkill(juluan.name) and target == player and #player.room.logic:getActualDamageEvents(2, function (e)
      return e.data[1].from == player
    end, Player.HistoryTurn) == 1
  end,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + 1
  end,
})

juluan:addEffect(fk.DamageInflicted, {
  can_trigger = function(self, event, target, player)
    return player:hasSkill(juluan.name) and target == player and #player.room.logic:getActualDamageEvents(2, function (e)
      return e.data[1].to == player
    end, Player.HistoryTurn) == 1
  end,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + 1
  end,
})

return juluan
