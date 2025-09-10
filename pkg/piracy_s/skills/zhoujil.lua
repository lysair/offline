local zhoujil = fk.CreateSkill({
  name = "ofl__zhoujil",
})

Fk:loadTranslationTable{
  ["ofl__zhoujil"] = "周济",
  [":ofl__zhoujil"] = "出牌阶段限X次，你可以与一名角色拼点，若其赢，其摸两张牌（X为你的体力值）。",

  ["#ofl__zhoujil"] = "周济：与一名角色拼点，若其赢，其摸两张牌",
}

zhoujil:addEffect("active", {
  anim_type = "support",
  prompt = "#ofl__zhoujil",
  card_num = 0,
  target_num = 1,
  times = function(self, player)
    return player.phase == Player.Play and player.hp - player:usedSkillTimes(zhoujil.name, Player.HistoryPhase) or -1
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(zhoujil.name, Player.HistoryPhase) < player.hp
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player and player:canPindian(to_select)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local pindian = player:pindian({target}, zhoujil.name)
    if pindian.results[target].winner == target and not target.dead then
      target:drawCards(2, zhoujil.name)
    end
  end,
})

return zhoujil
