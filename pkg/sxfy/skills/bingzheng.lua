local bingzheng = fk.CreateSkill{
  name = "sxfy__bingzheng",
}

Fk:loadTranslationTable{
  ["sxfy__bingzheng"] = "秉正",
  [":sxfy__bingzheng"] = "结束阶段，你可以令一名角色弃置一张牌，然后若其手牌数不等于体力值，你失去1点体力。",

  ["#sxfy__bingzheng-choose"] = "秉正：令一名角色弃置一张牌，若其手牌数不等于体力值，你失去1点体力",
}

bingzheng:addEffect(fk.EventPhaseEnd, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(bingzheng.name) and player.phase == Player.Finish and
      table.find(player.room.alive_players, function(p)
        return not p:isNude()
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function(p)
      return not p:isNude()
    end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = bingzheng.name,
      prompt = "#sxfy__bingzheng-choose",
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
    room:askToDiscard(to, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = bingzheng.name,
      cancelable = false,
    })
    if not player.dead and to.hp ~= to:getHandcardNum() then
      room:loseHp(player, 1, bingzheng.name)
    end
  end,
})

return bingzheng
