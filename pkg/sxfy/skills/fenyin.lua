local fenyin = fk.CreateSkill {
  name = "sxfy__fenyin",
}

Fk:loadTranslationTable{
  ["sxfy__fenyin"] = "奋音",
  [":sxfy__fenyin"] = "摸牌阶段，你可以多摸两张牌，若如此做，当你本回合使用牌时，若此牌与你本回合使用的上一张牌颜色相同，你须弃置一张牌。",

  ["@sxfy__fenyin-turn"] = "奋音",
}

fenyin:addEffect(fk.DrawNCards, {
  anim_type = "drawcard",
  on_use = function(self, event, target, player, data)
    data.n = data.n + 2
  end,
})

fenyin:addEffect(fk.CardUsing, {
  anim_type = "negative",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:usedSkillTimes(fenyin.name, Player.HistoryTurn) > 0 and
      not player:isNude() and data.extra_data and data.extra_data.sxfy__fenyin
  end,
  on_use = function(self, event, target, player, data)
    player.room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = fenyin.name,
      cancelable = false,
    })
  end,
})

fenyin:addEffect(fk.AfterCardUseDeclared, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:usedSkillTimes(fenyin.name, Player.HistoryTurn) > 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local color = data.card:getColorString()
    if color == "nocolor" then
      room:setPlayerMark(player, "@sxfy__fenyin-turn", 0)
    else
      if color == player:getMark("@sxfy__fenyin-turn") then
        data.extra_data = data.extra_data or {}
        data.extra_data.sxfy__fenyin = true
      end
      room:setPlayerMark(player, "@sxfy__fenyin-turn", color)
    end
  end,
})

return fenyin
