local fhyx__huimin = fk.CreateSkill {
  name = "fhyx__huimin"
}

Fk:loadTranslationTable{
  ['fhyx__huimin'] = '惠民',
  ['#fhyx__huimin-choose'] = '惠民：选择任意名手牌数小于体力值的角色，你摸等量牌，然后交给这些角色各一张手牌',
  ['#fhyx__huimin-give'] = '惠民：请交给这些角色各一张手牌',
  [':fhyx__huimin'] = '结束阶段，你可以选择任意名手牌数小于体力值的角色，你摸等量的牌，然后交给这些角色各一张手牌。',
}

fhyx__huimin:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player)
    return target == player and player:hasSkill(skill.name) and player.phase == Player.Finish and
      table.find(player.room.alive_players, function (p)
        return p:getHandcardNum() < p.hp
      end)
  end,
  on_cost = function(self, event, target, player)
    local room = player.room
    local targets = table.map(table.filter(room.alive_players, function (p)
      return p:getHandcardNum() < p.hp
    end), Util.IdMapper)
    local tos = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 999,
      prompt = "#fhyx__huimin-choose",
      skill_name = skill.name,
      cancelable = true
    })
    if #tos > 0 then
      room:sortPlayersByAction(tos)
      event:setCostData(skill, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    player:drawCards(#event:getCostData(skill).tos, skill.name)
    if player.dead or player:isKongcheng() then return end
    local targets = table.filter(event:getCostData(skill).tos, function (id)
      return not room:getPlayerById(id).dead
    end)
    if #targets == 0 then return end
    local n = math.min(player:getHandcardNum(), #targets)
    room:askToYiji(player, {
      cards = player:getCardIds("h"),
      targets = table.map(targets, Util.Id2PlayerMapper),
      skill_name = skill.name,
      min_num = n,
      max_num = n,
      prompt = "#fhyx__huimin-give",
      single_max = 1
    })
  end
})

return fhyx__huimin
