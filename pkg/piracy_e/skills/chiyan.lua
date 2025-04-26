local chiyan = fk.CreateSkill {
  name = "ofl__chiyan",
}

Fk:loadTranslationTable{
  ["ofl__chiyan"] = "鸱嚥",
  [":ofl__chiyan"] = "当你使用【杀】指定一个目标后，你可以令目标角色和你依次将任意张牌置于各自的武将牌上直到回合结束，若其手牌数"..
  "不大于你，其本回合受到的伤害+1；不小于你，其本回合不能使用手牌。",

  ["#ofl__chiyan-invoke"] = "鸱嚥：是否令 %dest 和你依次将任意张牌置于武将牌上直到回合结束？",
  ["#ofl__chiyan1-put"] = "鸱嚥：将任意张牌置于武将牌上，若手牌数不大于 %src 则受伤+1，若不小于则不能使用手牌",
  ["#ofl__chiyan2-put"] = "鸱嚥：将任意张牌置于武将牌上，若手牌数不小于 %dest 则其受伤+1，若不大于则其不能使用手牌",
  ["$ofl__chiyan"] = "鸱嚥",

  ["@ofl__chiyan_damage-turn"] = "受到伤害+",
  ["@@ofl__chiyan_hand-turn"] = "不能使用手牌",

  ["$ofl__chiyan1"] = "逆臣乱党，都要受这啄心之刑。",
  ["$ofl__chiyan2"] = "汝此等语，何不以溺自照？",
}

chiyan:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(chiyan.name) and data.card.trueName == "slash"
  end,
  on_cost = function (self, event, target, player, data)
    if player.room:askToSkillInvoke(player, {
      skill_name = chiyan.name,
      prompt = "#ofl__chiyan-invoke::" .. data.to.id,
    }) then
      event:setCostData(self, {tos = {data.to}})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if not data.to:isNude() then
      local cards = room:askToCards(data.to, {
        min_num = 1,
        max_num = 999,
        skill_name = chiyan.name,
        prompt = "#ofl__chiyan1-put:" .. player.id,
      })
      if #cards > 0 then
        data.to:addToPile("$ofl__chiyan", cards, false, chiyan.name, data.to)
      end
    end
    if not player.dead and not player:isNude() then
      local cards = room:askToCards(player, {
        min_num = 1,
        max_num = 999,
        skill_name = chiyan.name,
        prompt = "#ofl__chiyan2-put::" .. data.to.id,
      })
      if #cards > 0 then
        player:addToPile("$ofl__chiyan", cards, false, chiyan.name, player)
      end
    end
    if not data.to.dead then
      if data.to:getHandcardNum() <= player:getHandcardNum() then
        room:addPlayerMark(data.to, "@ofl__chiyan_damage-turn", 1)
      end
      if data.to:getHandcardNum() >= player:getHandcardNum() then
        room:setPlayerMark(data.to, "@@ofl__chiyan_hand-turn", 1)
      end
    end
  end,
})

chiyan:addEffect(fk.DamageInflicted, {
  anim_type = "negative",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@ofl__chiyan_damage-turn") > 0
  end,
  on_use = function(self, event, target, player, data)
    data:changeDamage(player:getMark("@ofl__chiyan_damage-turn"))
  end,
})

chiyan:addEffect(fk.TurnEnd, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return #player:getPile("$ofl__chiyan") > 0
  end,
  on_use = function(self, event, target, player, data)
    player.room:moveCardTo(player:getPile("$ofl__chiyan"), Card.PlayerHand, player, fk.ReasonJustMove)
  end,
})

chiyan:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    if player:getMark("@@ofl__chiyan_hand-turn") > 0 then
      local subcards = card:isVirtual() and card.subcards or {card.id}
      return #subcards > 0 and table.every(subcards, function(id)
        return table.contains(player:getCardIds("h"), id)
      end)
    end
  end,
})

return chiyan
