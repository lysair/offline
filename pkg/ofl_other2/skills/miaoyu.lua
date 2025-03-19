local miaoyu = fk.CreateSkill {
  name = "ofl__miaoyu"
}

Fk:loadTranslationTable{
  ['ofl__miaoyu'] = '妙语',
  ['#ofl__miaoyu-invoke'] = '妙语：是否将牌堆顶牌交给 %dest？本回合结束时其失去体力',
  ['@ofl__miaoyu-turn'] = '妙语',
  ['#ofl__miaoyu_delay'] = '妙语',
  [':ofl__miaoyu'] = '当一名角色回复体力后，你可以将牌堆顶一张牌交给其，当前回合结束时，其失去X点体力（X为你本回合发动此技能次数）。',
  ['$ofl__miaoyu1'] = '小伤无碍，安心修养便可。',
  ['$ofl__miaoyu2'] = '若非吾之相助，汝安有今日？',
}

miaoyu:addEffect(fk.HpRecover, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(miaoyu.name) and not target.dead
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askToSkillInvoke(player, {skill_name = miaoyu.name, prompt = "#ofl__miaoyu-invoke::" .. target.id}) then
      event:setCostData(miaoyu, {tos = {target.id}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(target, "@ofl__miaoyu-turn", player:usedSkillTimes(miaoyu.name, Player.HistoryTurn))
    for _, p in ipairs(room:getOtherPlayers(target)) do
      if p:getMark("@ofl__miaoyu-turn") > 0 then
        room:setPlayerMark(p, "@ofl__miaoyu-turn", player:usedSkillTimes(miaoyu.name, Player.HistoryTurn))
      end
    end
    room:moveCardTo(room:getNCards(1), Card.PlayerHand, target, fk.ReasonGive, miaoyu.name, nil, false, player.id)
  end,
})

miaoyu:addEffect(fk.TurnEnd, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:usedSkillTimes(miaoyu.name, Player.HistoryTurn) > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getAlivePlayers()) do
      if not p.dead and p:getMark("@ofl__miaoyu-turn") > 0 then
        room:loseHp(p, player:usedSkillTimes(miaoyu.name, Player.HistoryTurn), "ofl__miaoyu")
      end
    end
  end,
})

return miaoyu
