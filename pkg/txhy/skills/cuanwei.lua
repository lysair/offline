local cuanwei = fk.CreateSkill {
  name = "ofl_tx__cuanwei",
}

Fk:loadTranslationTable{
  ["ofl_tx__cuanwei"] = "篡位",
  [":ofl_tx__cuanwei"] = "<a href='os__presumption'>妄行</a>：出牌阶段开始时，你可以失去1点体力，令一名角色选择一项："..
  "1.令你获得其X张牌（不足则无法选择）；2.失去X点体力。",

  ["#ofl_tx__cuanwei-choose"] = "篡位：失去1点体力并选择1~4，令一名角色选择你获得其等量牌或其失去等量体力",
  ["#ofl_tx__cuanwei-choice"] = "篡位：点“确定”%src 获得你%arg张牌，或点“取消”你失去%arg点体力！",
  ["@ofl_tx__cuanwei_presume-turn"] = "篡位 妄行",
  ["#ofl_tx__cuanwei_presume-discard"] = "篡位：弃置%arg张牌，否则减1点体力上限",
}

cuanwei:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(cuanwei.name) and player.phase == Player.Play and
      player.hp > 0
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local success, dat = room:askToUseActiveSkill(player, {
      skill_name = "#ofl_tx__cuanwei_active",
      prompt = "#ofl_tx__cuanwei-choose",
      cancelable = true,
    })
    if success and dat then
      event:setCostData(self, { tos = dat.targets, choice = dat.interaction })
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local choice = event:getCostData(self).choice
    room:setPlayerMark(player, "@ofl_tx__cuanwei_presume-turn", choice)
    if #to:getCardIds("he") < choice or
      not room:askToSkillInvoke(to, {
        skill_name = cuanwei.name,
        prompt = "#ofl_tx__cuanwei-choice:"..player.id.."::"..choice,
      }) then
      room:loseHp(to, choice, cuanwei.name)
    else
      local cards = room:askToChooseCards(player, {
        target = to,
        min = choice,
        max = choice,
        flag = "he",
        skill_name = cuanwei.name,
      })
      room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonPrey, cuanwei.name, nil, false, player)
    end
  end,
})

cuanwei:addEffect(fk.EventPhaseStart, {
  anim_type = "negative",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return player == target and player.phase == Player.Finish and
      player:getMark("@ofl_tx__cuanwei_presume-turn") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local num = player:getMark("@ofl_tx__cuanwei_presume-turn")
    if #room:askToDiscard(player, {
      min_num = num,
      max_num = num,
      include_equip = true,
      skill_name = cuanwei.name,
      prompt = "#ofl_tx__cuanwei_presume-discard:::" .. num,
    }) == 0 then
      room:changeMaxHp(player, -1)
    end
  end,
})

return cuanwei
