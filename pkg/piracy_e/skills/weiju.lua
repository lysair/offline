local weiju = fk.CreateSkill {
  name = "weiju",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["weiju"] = "威惧",
  [":weiju"] = "锁定技，准备阶段，所有其他角色依次将任意张手牌置于其武将牌上直到回合结束，称为“惧”。若一名角色的“惧”数不大于其手牌数，"..
  "你与其互相视为在对方的攻击范围内。",

  ["$weiju"] = "惧",
  ["#weiju-ask"] = "威惧：请将任意张手牌置于武将牌上直到回合结束",
}

weiju:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(weiju.name) and player.phase == Player.Start and
      #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = function (self, event, target, player, data)
    event:setCostData(self, {tos = player.room:getOtherPlayers(player)})
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if not p.dead and not p:isKongcheng() then
        local cards = room:askToCards(p, {
          min_num = 1,
          max_num = p:getHandcardNum(),
          include_equip = false,
          skill_name = weiju.name,
          cancelable = true,
          prompt = "#weiju-ask",
        })
        if #cards > 0 then
          p:addToPile("$weiju", cards, false, weiju.name, p)
        end
      end
    end
  end,
})

weiju:addEffect("atkrange", {
  within_func = function (self, from, to)
    if from:hasSkill(weiju.name) and #to:getPile("$weiju") <= to:getHandcardNum() then
      return true
    end
    if to:hasSkill(weiju.name) and #from:getPile("$weiju") <= from:getHandcardNum() then
      return true
    end
  end,
})

weiju:addEffect(fk.TurnEnd, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return not player.dead and #player:getPile("$weiju") > 0
  end,
  on_use = function(self, event, target, player, data)
    player.room:moveCardTo(player:getPile("$weiju"), Player.Hand, player, fk.ReasonJustMove, weiju.name)
  end,
})

return weiju
