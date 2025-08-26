local yicong = fk.CreateSkill({
  name = "ofl_mou__yicong",
})

Fk:loadTranslationTable{
  ["ofl_mou__yicong"] = "义从",
  [":ofl_mou__yicong"] = "每轮开始时，你可以令你本轮计算与其他角色的距离-1/其他角色本轮计算与你的距离+1，然后亮出牌堆顶四张牌，"..
  "将其中所有【杀】/【闪】置于你的武将牌上，称为“扈”（你至多拥有四张“扈”）。你可以将“扈”如手牌般使用或打出。",

  ["ofl_mou__yicong_offensive"] = "本轮你至其他角色距离-1",
  ["ofl_mou__yicong_defensive"] = "本轮其他角色至你距离+1",
  ["@@ofl_mou__yicong_offensive-round"] = "义从 -1",
  ["@@ofl_mou__yicong_defensive-round"] = "义从 +1",
  ["ofl_mou__yicong_hu"] = "扈",

  ["$ofl_mou__yicong1"] = "跟着我，一起上！",
  ["$ofl_mou__yicong2"] = "齐兵后撤！",
}

yicong:addEffect(fk.RoundStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(yicong.name)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local choice = room:askToChoice(player, {
      choices = {
        "ofl_mou__yicong_offensive",
        "ofl_mou__yicong_defensive",
        "Cancel",
      },
      skill_name = yicong.name,
    })
    if choice ~= "Cancel" then
      event:setCostData(self, {choice = choice})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = event:getCostData(self).choice
    room:setPlayerMark(player, "@@"..choice.."-round", 1)
    local cards = room:getNCards(4)
    room:turnOverCardsFromDrawPile(player, cards, yicong.name)
    local ids = table.filter(cards, function (id)
      return Fk:getCardById(id).trueName == (choice == "ofl_mou__yicong_defensive" and "jink" or "slash")
    end)
    if #ids > 0 and #player:getPile("ofl_mou__yicong_hu") < 4 then
      player:addToPile("ofl_mou__yicong_hu", table.random(ids, 4 - #player:getPile("ofl_mou__yicong_hu")), true, yicong.name)
    end
    room:cleanProcessingArea(cards)
  end,
})

yicong:addEffect("distance", {
  correct_func = function(self, from, to)
    local n = 0
    if from:getMark("@@ofl_mou__yicong_offensive-round") > 0 then
      n = n - 1
    end
    if to:getMark("@@ofl_mou__yicong_defensive-round") > 0 then
      n = n + 1
    end
    return n
  end,
})

yicong:addEffect("filter", {
  handly_cards = function (self, player)
    if player:hasSkill(yicong.name) then
      return player:getPile("ofl_mou__yicong_hu")
    end
  end,
})

return yicong
