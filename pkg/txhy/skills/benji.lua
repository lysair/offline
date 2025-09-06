local benji = fk.CreateSkill {
  name = "ofl_tx__benji",
}

Fk:loadTranslationTable{
  ["ofl_tx__benji"] = "奔激",
  [":ofl_tx__benji"] = "回合开始时，你可以对一名角色造成X点伤害，若其未因此进入濒死状态，你失去1点体力（X为你已损失体力值）。",

  ["#ofl_tx__benji-choose"] = "奔激：你可以对一名角色造成%arg点伤害，若其未进入濒死状态你失去1点体力",
}

benji:addEffect(fk.TurnStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(benji.name) and
      player:isWounded()
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room.alive_players,
      skill_name = benji.name,
      prompt = "#ofl_tx__benji-choose:::"..player:getLostHp(),
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
    room:setPlayerMark(player, "ofl_tx__benji-phase", 1)
    room:damage{
      from = player,
      to = to,
      damage = player:getLostHp(),
      skillName = benji.name,
    }
    if player.dead then return end
    if player:getMark("ofl_tx__benji-phase") > 0 then
      room:setPlayerMark(player, "ofl_tx__benji-phase", 0)
      room:loseHp(player, 1, benji.name)
    end
  end,
})

benji:addEffect(fk.EnterDying, {
  can_refresh = function(self, event, target, player, data)
    if data.damage and data.damage.skillName == benji.name then
      local skill_effect = player.room.logic:getCurrentEvent():findParent(GameEvent.SkillEffect)
      return skill_effect and skill_effect.data.who == player
    end
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "ofl_tx__benji-phase", 0)
  end,
})

return benji
