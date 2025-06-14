local renwang = fk.CreateSkill {
  name = "renwang",
}

Fk:loadTranslationTable{
  ["renwang"] = "仁望",
  [":renwang"] = "出牌阶段，你可以将至少两张牌交给一名其他角色，然后回复1点体力且本回合出牌阶段使用【杀】次数上限+1。",

  ["#renwang"] = "仁望：将至少两张牌交给一名角色，然后回复1点体力且【杀】次数+1",
}

renwang:addEffect("active", {
  anim_type = "support",
  prompt = "#renwang",
  min_card_num = 2,
  target_num = 1,
  card_filter = Util.TrueFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and #selected_cards > 1 and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local cards = effect.cards
    room:moveCardTo(cards, Player.Hand, target, fk.ReasonGive, renwang.name, nil, false, player)
    if not player.dead then
      room:addPlayerMark(player, MarkEnum.SlashResidue.."-turn", 1)
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = renwang.name,
      }
    end
  end,
})

return renwang
