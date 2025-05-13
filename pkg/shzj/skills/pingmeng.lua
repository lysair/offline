local pingmeng = fk.CreateSkill({
  name = "pingmeng",
})

Fk:loadTranslationTable{
  ["pingmeng"] = "平孟",
  [":pingmeng"] = "当你使用【杀】后或失去最后一张手牌后，你可以变更势力并将手牌补至体力上限，然后当前回合结束阶段，你可以视为使用一张【杀】。",

  ["#pingmeng-invoke"] = "平孟：你可以变更势力并将手牌补至体力上限，本回合结束阶段可以视为使用【杀】",
  ["#pingmeng-slash"] = "平孟：你可以视为使用一张【杀】",
}

local spec = {
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local all_choices = Fk:getKingdomMap("god")
    table.insert(all_choices, "Cancel")
    local choices = table.simpleClone(all_choices)
    table.removeOne(choices, player.kingdom)
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = pingmeng.name,
      prompt = "#pingmeng-invoke",
      all_choices = all_choices,
    })
    if choice ~= "Cancel" then
      event:setCostData(self, {choice = choice})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeKingdom(player, event:getCostData(self).choice, true)
    if not player.dead and player:getHandcardNum() < player.maxHp then
      player:drawCards(player.maxHp - player:getHandcardNum(), pingmeng.name)
    end
  end,
}

pingmeng:addEffect(fk.CardUseFinished, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(pingmeng.name) and data.card.trueName == "slash"
  end,
  on_cost = spec.on_cost,
  on_use = spec.on_use,
})
pingmeng:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not (player:hasSkill(pingmeng.name) and player:isKongcheng()) then return end
    for _, move in ipairs(data) do
      if move.from == player then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand then
            return true
          end
        end
      end
    end
  end,
  on_cost = spec.on_cost,
  on_use = spec.on_use,
})

pingmeng:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target.phase == Player.Finish and player:usedSkillTimes(pingmeng.name, Player.HistoryTurn) > 0 and
      not player.dead and player:canUse(Fk:cloneCard("slash"), {bypass_times = true})
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local use = room:askToUseVirtualCard(player, {
      name = "slash",
      skill_name = pingmeng.name,
      prompt = "#pingmeng-slash",
      cancelable = true,
      extra_data = {
        bypass_times = true,
        extraUse = true,
      },
      skip = true,
    })
    if use then
      event:setCostData(self, {extra_data = use})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:useCard(event:getCostData(self).extra_data)
  end,
})

return pingmeng
