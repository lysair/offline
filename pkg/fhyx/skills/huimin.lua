local huimin = fk.CreateSkill {
  name = "fhyx__huimin",
}

Fk:loadTranslationTable{
  ["fhyx__huimin"] = "惠民",
  [":fhyx__huimin"] = "结束阶段，你可以选择任意名手牌数小于体力值的角色，你摸等量的牌，然后交给这些角色各一张手牌。",

  ["#fhyx__huimin-choose"] = "惠民：选择任意名手牌数小于体力值的角色，你摸等量牌，然后交给这些角色各一张手牌",
  ["#fhyx__huimin-give"] = "惠民：请交给这些角色各一张手牌",

  ["$fhyx__huimin1"] = "惠山阳之民，更愿泽披天下黎庶。",
  ["$fhyx__huimin2"] = "与夫君救百姓于水火，亦是幸事。",
}

huimin:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(huimin.name) and player.phase == Player.Finish and
      table.find(player.room.alive_players, function (p)
        return p:getHandcardNum() < p.hp
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function (p)
      return p:getHandcardNum() < p.hp
    end)
    local tos = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 10,
      prompt = "#fhyx__huimin-choose",
      skill_name = huimin.name,
      cancelable = true
    })
    if #tos > 0 then
      room:sortByAction(tos)
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(#event:getCostData(self).tos, huimin.name)
    if player.dead or player:isKongcheng() then return end
    local targets = table.filter(event:getCostData(self).tos, function (p)
      return not p.dead
    end)
    if #targets == 0 then return end
    local n = math.min(player:getHandcardNum(), #targets)
    room:askToYiji(player, {
      cards = player:getCardIds("h"),
      targets = targets,
      skill_name = huimin.name,
      min_num = n,
      max_num = n,
      prompt = "#fhyx__huimin-give",
      single_max = 1
    })
  end
})

return huimin
