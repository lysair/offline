local qingbei = fk.CreateSkill {
  name = "sxfy__qingbei",
}

Fk:loadTranslationTable{
  ["sxfy__qingbei"] = "擎北",
  [":sxfy__qingbei"] = "每轮开始时，你可以选择一种颜色令你本轮无法使用，然后本轮你使用一张手牌后，你令一名角色摸一张牌。",

  ["@sxfy__qingbei-round"] = "擎北",
  ["#sxfy__qingbei-choice"] = "擎北：选择你本轮不能使用的颜色",
  ["#sxfy__qingbei-choose"] = "擎北：令一名角色摸一张牌",
}

qingbei:addEffect(fk.RoundStart, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(qingbei.name)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local choice = room:askToChoice(player, {
      choices = {"red", "black", "Cancel"},
      skill_name = qingbei.name,
      prompt = "#sxfy__qingbei-choice",
      cancelable = true,
    })
    if choice ~= "Cancel" then
      event:setCostData(self, {choice = choice})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@sxfy__qingbei-round", event:getCostData(self).choice)
  end,
})

qingbei:addEffect(fk.CardUseFinished, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(qingbei.name) and
      player:getMark("@sxfy__qingbei-round") ~= 0 and data:isUsingHandcard(player)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room.alive_players,
      skill_name = qingbei.name,
      prompt = "#sxfy__qingbei-choose",
      cancelable = false,
    })[1]
    to:drawCards(1, qingbei.name)
  end,
})

qingbei:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    return card and player:getMark("@sxfy__qingbei-round") == card:getColorString()
  end,
})

return qingbei
