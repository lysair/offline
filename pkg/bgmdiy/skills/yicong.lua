local yicong = fk.CreateSkill {
  name = "bgm__yicong",
}

Fk:loadTranslationTable{
  ["bgm__yicong"] = "义从",
  [":bgm__yicong"] = "弃牌阶段结束时，你可以将任意张牌置于武将牌上，称为“扈”。其他角色与你的距离+X。（X为“扈”的数量）",

  ["bgm_follower"] = "扈",
  ["#bgm__yicong-invoke"] = "义从：你可以将任意张牌置为“扈”，其他角色与你距离增加“扈”的数量",
}

yicong:addEffect(fk.EventPhaseEnd, {
  anim_type = "control",
  derived_piles = "bgm_follower",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yicong.name) and player.phase == Player.Discard and
      not player:isNude()
  end,
  on_cost = function (self, event, target, player, data)
    local cards = player.room:askToCards(player, {
      min_num = 1,
      max_num = 999,
      include_equip = true,
      skill_name = yicong.name,
      cancelable = true,
      prompt = "#bgm__yicong-invoke",
    })
    if #cards > 0 then
      event:setCostData(self, {cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player:addToPile("bgm_follower", event:getCostData(self).cards, true, yicong.name)
  end,
})

yicong:addEffect("distance", {
  correct_func = function(self, from, to)
    if to:hasSkill(yicong.name) then
      return #to:getPile("bgm_follower")
    end
  end,
})

return yicong
