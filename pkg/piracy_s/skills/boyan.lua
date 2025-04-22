local boyan = fk.CreateSkill({
  name = "ofl__boyan",
})

Fk:loadTranslationTable{
  ["ofl__boyan"] = "驳言",
  [":ofl__boyan"] = "出牌阶段限两次，你可以与一名角色拼点，没赢的角色本回合不能使用手牌并摸两张牌。",

  ["#ofl__boyan"] = "驳言：与一名角色拼点，没赢的角色摸两张牌且本回合不能使用手牌",
  ["@@ofl__boyan-turn"] = "驳言 禁用手牌",
}

boyan:addEffect("active", {
  anim_type = "control",
  prompt = "#ofl__boyan",
  max_phase_use_time = 2,
  card_num = 0,
  target_num = 1,
  times = function(self, player)
    return player.phase == Player.Play and 2 - player:usedSkillTimes(boyan.name, Player.HistoryPhase) or -1
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(boyan.name, Player.HistoryPhase) < 2
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player and player:canPindian(to_select)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local pindian = player:pindian({target}, boyan.name)
    if pindian.results[target].winner ~= player then
      if not player.dead then
        room:setPlayerMark(player, "@@ofl__boyan-turn", 1)
        player:drawCards(2, boyan.name)
      end
    end
    if pindian.results[target].winner ~= target then
      if not target.dead then
        room:setPlayerMark(target, "@@ofl__boyan-turn", 1)
        target:drawCards(2, boyan.name)
      end
    end
  end,
})

boyan:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    if card and player:getMark("@@ofl__boyan-turn") > 0 then
      local subcards = card:isVirtual() and card.subcards or {card.id}
      return #subcards > 0 and
        table.every(subcards, function(id)
          return table.contains(player:getCardIds("h"), id)
        end)
    end
  end,
})

return boyan
