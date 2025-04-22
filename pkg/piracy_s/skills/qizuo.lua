local qizuo = fk.CreateSkill {
  name = "ofl__qizuo",
}

Fk:loadTranslationTable{
  ["ofl__qizuo"] = "奇佐",
  [":ofl__qizuo"] = "当你攻击范围内的角色造成或受到伤害时，你可以弃置一张牌进行一次判定，若结果与你弃置的牌颜色相同，你可以令此伤害+1或-1。",

  ["#ofl__qizuo1-invoke"] = "奇佐：%src 对 %dest 造成伤害，你可以弃置一张牌进行判定，令此伤害+1或-1",
  ["#ofl__qizuo2-invoke"] = "奇佐：%dest 受到伤害，你可以弃置一张牌进行判定，令此伤害+1或-1",
  ["#ofl__qizuo1-choice"] = "奇佐：你可以令 %src 对 %dest 造成的伤害+1或-1",
  ["#ofl__qizuo2-choice"] = "奇佐：你可以令 %dest 受到的伤害+1或-1",
}

local spec = {
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local prompt
    if event == fk.DamageCaused then
      prompt = "#ofl__qizuo1-invoke:"..target.id..":"..data.to.id
    else
      prompt = "#ofl__qizuo2-invoke::"..target.id
    end
    local card = room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = qizuo.name,
      cancelable = true,
      prompt = prompt,
      skip = true,
    })
    if #card > 0 then
      event:setCostData(self, {tos = {target}, cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = Fk:getCardById(event:getCostData(self).cards[1])
    room:throwCard(card, qizuo.name, player, player)
    if player.dead then return false end
    local pattern = "false"
    if card.color == Card.Black then
      pattern = ".|.|spade,club"
    elseif card.color == Card.Red then
      pattern = ".|.|heart,diamond"
    end
    local judge = {
      who = player,
      reason = qizuo.name,
      pattern = pattern,
    }
    room:judge(judge)
    if judge:matchPattern() and not player.dead then
      local prompt
      if event == fk.DamageCaused then
        prompt = "#ofl__qizuo1-choice:"..target.id..":"..data.to.id
      else
        prompt = "#ofl__qizuo2-choice::"..target.id
      end
      local choice = room:askToChoice(player, {
        choices = {"+1", "-1", "Cancel"},
        skill_name = qizuo.name,
        prompt = prompt,
      })
      if choice == "+1" then
        data:changeDamage(1)
      elseif choice == "-1" then
        data:changeDamage(-1)
      end
    end
  end,
}

qizuo:addEffect(fk.DamageCaused, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(qizuo.name) and target and player:inMyAttackRange(target) and not player:isNude()
  end,
  on_cost = spec.on_cost,
  on_use = spec.on_use,
})

qizuo:addEffect(fk.DamageInflicted, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(qizuo.name) and player:inMyAttackRange(target) and not player:isNude()
  end,
  on_cost = spec.on_cost,
  on_use = spec.on_use,
})

return qizuo
