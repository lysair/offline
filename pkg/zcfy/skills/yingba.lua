local yingba = fk.CreateSkill {
  name = "sxfy__yingba",
}

Fk:loadTranslationTable{
  ["sxfy__yingba"] = "英霸",
  [":sxfy__yingba"] = "出牌阶段限一次，你可以令一名体力上限大于1的其他角色减1点体力上限，然后你减1点体力上限。",

  ["#sxfy__yingba"] = "英霸：与一名角色各减1点体力上限",
}

yingba:addEffect("active", {
  anim_type = "offensive",
  prompt = "#sxfy__yingba",
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(yingba.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return to_select ~= player and to_select.maxHp > 1
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:changeMaxHp(target, -1)
    if not player.dead then
      room:changeMaxHp(player, -1)
    end
  end,
})

return yingba
