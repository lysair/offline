local zhiyi = fk.CreateSkill {
  name = "sxfy__zhiyi",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["sxfy__zhiyi"] = "执义",
  [":sxfy__zhiyi"] = "锁定技，你使用过【杀】的回合结束时，你摸一张牌或视为使用一张【杀】。",

  ["#sxfy__zhiyi-slash"] = "执义：视为使用一张【杀】，或点“取消”摸一张牌",
}

zhiyi:addEffect(fk.TurnEnd, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(zhiyi.name) and
      #player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
        local use = e.data
        return use.from == player and use.card.trueName == "slash"
      end, Player.HistoryTurn) > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if not room:askToUseVirtualCard(player, {
      name = "slash",
      skill_name = zhiyi.name,
      prompt = "#sxfy__zhiyi-slash",
      cancelable = true,
      extra_data = {
        bypass_times = true,
        extraUse = true,
      },
    }) then
      player:drawCards(1, zhiyi.name)
    end
  end,
})

return zhiyi
