local shuangren = fk.CreateSkill {
  name = "ofl__shuangren",
}

Fk:loadTranslationTable{
  ["ofl__shuangren"] = "双刃",
  [":ofl__shuangren"] = "出牌阶段，你可以与一名角色拼点。若你赢，你可以依次视为使用X张【杀】；若你没赢，本回合你的【杀】视为K点的【闪】"..
  "（X为你本回合拼点赢的次数）。",

  ["#ofl__shuangren"] = "双刃：你可以拼点，若赢你可以视为使用【杀】，若没赢本回合你的【杀】视为K点的【闪】",
  ["#ofl__shuangren-slash"] = "双刃：你可以视为使用【杀】（第%arg张，共%arg2张）",
}

shuangren:addEffect("active", {
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  prompt = "#ofl__shuangren",
  can_use = function(self, player)
    return not player:isKongcheng()
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player and player:canPindian(to_select)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local pindian = player:pindian({target}, shuangren.name)
    if player.dead then return end
    if pindian.results[target].winner == player then
      local n = #room.logic:getEventsOfScope(GameEvent.Pindian, 999, function(e)
        local dat = e.data
        if dat.from == player then
          for _, result in pairs(dat.results) do
            if result.winner == player then
              return true
            end
          end
        end
        if dat.results[player] and dat.results[player].winner == player then
          return true
        end
      end, Player.HistoryTurn)
      for i = 1, n, 1 do
        if player.dead or not room:askToUseVirtualCard(player, {
          name = "slash",
          skill_name = shuangren.name,
          prompt = "#ofl__shuangren-slash:::"..i..":"..n,
          cancelable = true,
          extra_data = {
            bypass_times = true,
            extraUse = true,
          }
        }) then
          break
        end
      end
    else
      room:setPlayerMark(player, "ofl__shuangren-turn", 1)
      player:filterHandcards()
    end
  end,
})

shuangren:addEffect("filter", {
  mute = true,
  card_filter = function(self, card, player, isJudgeEvent)
    return player:getMark("ofl__shuangren-turn") > 0 and card.trueName == "slash" and
      (table.contains(player:getCardIds("h"), card.id) or isJudgeEvent)
  end,
  view_as = function(self, player, card)
    return Fk:cloneCard("jink", card.suit, 13)
  end,
})

return shuangren
