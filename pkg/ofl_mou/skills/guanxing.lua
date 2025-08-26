local guanxing = fk.CreateSkill({
  name = "ofl_mou__guanxing",
  derived_piles = "ofl_mou__guanxing_star",
})

Fk:loadTranslationTable{
  ["ofl_mou__guanxing"] = "观星",
  [":ofl_mou__guanxing"] = "准备阶段，你移去所有的“星”，并将牌堆顶X张牌置于武将牌上（X为7-此前此技能准备阶段发动次数的两倍），称为“星”。<br>"..
  "出牌阶段或结束阶段开始时，你可以将任意张“星”置于牌堆顶。<br>"..
  "你可以如手牌般使用或打出“星”。",

  ["ofl_mou__guanxing_star"] = "星",

  ["$ofl_mou__guanxing1"] = "荧惑守心犹不弃，且以此身逆乾坤！",
  ["$ofl_mou__guanxing2"] = "天命归人之笃行，不在隐现之群星！",
}

guanxing:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(guanxing.name) then
      if player.phase == Player.Start then
        return #player:getPile("ofl_mou__guanxing_star") > 0 or player:getMark("ofl_mou__guanxing_times") < 4
      elseif player.phase == Player.Play or player.phase == Player.Finish then
        return #player:getPile("ofl_mou__guanxing_star") > 0
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player.phase == Player.Start then
      if #player:getPile("ofl_mou__guanxing_star") > 0 then
        room:moveCards({
          from = player,
          ids = player:getPile("ofl_mou__guanxing_star"),
          toArea = Card.DiscardPile,
          moveReason = fk.ReasonPutIntoDiscardPile,
          skillName = guanxing.name,
          fromSpecialName = "ofl_mou__guanxing_star",
        })
        if not player:isAlive() then return false end
      end
      local n = 7 - 2 * player:getMark("ofl_mou__guanxing_times")
      if n < 1 then return end
      room:addPlayerMark(player, "ofl_mou__guanxing_times")
      player:addToPile("ofl_mou__guanxing_star", room:getNCards(n), false, guanxing.name)
      if not player:isAlive() or #player:getPile("ofl_mou__guanxing_star") == 0 then return false end
    else
      local result = room:askToGuanxing(player, {
        cards = player:getPile("ofl_mou__guanxing_star"),
        skill_name = guanxing.name,
        skip = true,
        area_names = { "ofl_mou__guanxing_star", "Top" }
      })
      if #result.bottom > 0 then
        room:moveCards({
          ids = table.reverse(result.bottom),
          from = player,
          fromArea = Card.PlayerSpecial,
          toArea = Card.DrawPile,
          moveReason = fk.ReasonJustMove,
          skillName = guanxing.name,
          fromSpecialName = "ofl_mou__guanxing_star",
        })
        room:sendLog{
          type = "#GuanxingResult",
          from = player.id,
          arg = #result.bottom,
          arg2 = 0,
        }
      end
    end
  end,
})

guanxing:addEffect("filter", {
  handly_cards = function (self, player)
    if player:hasSkill(guanxing.name) then
      return player:getPile("ofl_mou__guanxing_star")
    end
  end,
})

guanxing:addLoseEffect(function (self, player)
  player.room:setPlayerMark(player, "ofl_mou__guanxing_times", 0)
end)

return guanxing
