local feixiong = fk.CreateSkill {
  name = "feixiong"
}

Fk:loadTranslationTable{
  ['feixiong'] = '飞熊',
  ['#feixiong-ask'] = '飞熊：你可与一名其他角色拼点，拼点赢的角色对拼点未赢的角色造成1点伤害',
  [':feixiong'] = '出牌阶段开始时，你可与一名其他角色拼点，拼点赢的角色对拼点未赢的角色造成1点伤害。',
}

feixiong:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player)
    if not (target == player and player:hasSkill(feixiong) and player.phase == Player.Play and not player:isKongcheng()) then return end
    local targets = table.map(table.filter(player.room:getOtherPlayers(player, false), function (p)
      return not p:isKongcheng()
    end), Util.IdMapper)
    if #targets > 0 then
      event:setCostData(self, targets)
      return true
    end
  end,
  on_cost = function(self, event, target, player)
    local targets = event:getCostData(self)
    local target = player.room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#feixiong-ask",
      skill_name = feixiong.name
    })
    if #target > 0 then
      event:setCostData(self, target[1])
      return true
    end
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    player:broadcastSkillInvoke("langxi")
    local target = room:getPlayerById(event:getCostData(self))
    local pindian = player:pindian({target}, feixiong.name)
    local from = pindian.results[target.id].winner
    if from then
      local to = from == player and target or player
      room:damage{
        from = from,
        to = to,
        damage = 1,
        skillName = feixiong.name,
      }
    end
  end,
})

return feixiong
