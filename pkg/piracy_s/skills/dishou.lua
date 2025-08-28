local dishou = fk.CreateSkill {
  name = "ofl__dishou",
}

Fk:loadTranslationTable{
  ["ofl__dishou"] = "砥守",
  [":ofl__dishou"] = "当你受到伤害时，若伤害来源的手牌数和体力值不相等，其选择一项：1.弃置所有手牌；2.失去1点体力，"..
  "重复此流程直到手牌数和体力值相等或进入濒死状态。",

  ["#ofl__dishou-discard"] = "砥守：弃置所有手牌，或点“取消”失去1点体力并重复流程！",

  ["$ofl__dishou1"] = "捐躯赴时难，我何惜此头！",
  ["$ofl__dishou2"] = "书生尚敢战，况君英雄乎！",
}

dishou:addEffect(fk.DamageInflicted, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(dishou.name) and
      data.from and not data.from.dead and data.from.hp ~= data.from:getHandcardNum()
  end,
  on_cost = function(self, event, target, player, data)
    event:setCostData(self, {tos = {data.from}})
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    while not data.from.dead do
      room:setPlayerMark(data.from, dishou.name, 0)
      if table.find(data.from:getCardIds("h"), function (id)
        return not data.from:prohibitDiscard(id)
      end) then
        if room:askToSkillInvoke(data.from, {
          skill_name = dishou.name,
          prompt = "#ofl__dishou-discard",
        }) then
          data.from:throwAllCards("h", dishou.name)
          return
        end
      end
      room:loseHp(data.from, 1, dishou.name)
      if data.from.hp == data.from:getHandcardNum() or data.from:getMark(dishou.name) > 0 then
        room:setPlayerMark(data.from, dishou.name, 0)
        return
      end
    end
  end,
})

dishou:addEffect(fk.EnterDying, {
  can_refresh = function(self, event, target, player, data)
    return target == player and not player.dead
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, dishou.name, 1)
  end,
})

return dishou
