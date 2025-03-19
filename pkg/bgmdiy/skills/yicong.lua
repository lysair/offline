local yicong = fk.CreateSkill {
  name = "bgm__yicong"
}

Fk:loadTranslationTable{
  ['bgm__yicong'] = '义从',
  ['bgm_follower'] = '扈',
  ['#bgm__yicong-cost'] = '义从：你可以将至少一张牌置于武将牌上称为“扈”',
  [':bgm__yicong'] = '弃牌阶段结束时，你可以将至少一张牌置于武将牌上，称为“扈”。其他角色与你的距离+X。（X为“扈”的数量）',
}

yicong:addEffect(fk.EventPhaseEnd, {
  derived_piles = "bgm_follower",
  can_trigger = function(self, event, target, player)
    return player:hasSkill(yicong) and target == player and player.phase == Player.Discard and not player:isNude()
  end,
  on_cost = function (skill, event, target, player)
    local cards = player.room:askToCards(player, {
      min_num = 1,
      max_num = 9999,
      include_equip = true,
      skill_name = yicong.name,
      cancelable = true,
      prompt = "#bgm__yicong-cost",
    })
    if #cards > 0 then
      event:setCostData(skill, cards)
      return true
    end
  end,
  on_use = function(self, event, target, player)
    local cost_data = event:getCostData(skill)
    player:addToPile("bgm_follower", cost_data, true, yicong.name)
  end,
})

yicong:addEffect('distance', {
  name = "#bgm__yicong_distance",
  correct_func = function(self, from, to)
    if to:hasSkill(yicong) then
      return #to:getPile("bgm_follower")
    end
  end,
})

return yicong
