local fushi = fk.CreateSkill{
  name = "ofl_tx__fushi",
}

Fk:loadTranslationTable{
  ["ofl_tx__fushi"] = "附势",
  [":ofl_tx__fushi"] = "<a href='os__presumption'>妄行</a>：出牌阶段限一次，你可以弃置一名其他角色X+1张牌。",

  ["#ofl_tx__fushi"] = "附势：弃置一名其他角色(0~4)+1张牌，结束阶段执行妄行效果",
  ["@ofl_tx__fushi_presume-turn"] = "附势 妄行",
  ["#ofl_tx__fushi_presume-discard"] = "附势：弃置%arg张牌，否则减1点体力上限",
}

fushi:addEffect("active", {
  anim_type = "control",
  prompt = "#ofl_tx__fushi",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(fushi.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player and not to_select:isNude()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local cards = room:askToChooseCards(player, {
      min = 1,
      max = 5,
      target = target,
      flag = "he",
      skill_name = fushi.name,
    })
    if #cards > 1 then
      room:setPlayerMark(player, "@ofl_tx__fushi_presume-turn", #cards - 1)
    end
    room:throwCard(cards, fushi.name, target, player)
  end,
})

fushi:addEffect(fk.EventPhaseStart, {
  anim_type = "negative",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return player == target and player.phase == Player.Finish and
      player:getMark("@ofl_tx__fushi_presume-turn") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local num = player:getMark("@ofl_tx__fushi_presume-turn")
    if #room:askToDiscard(player, {
      min_num = num,
      max_num = num,
      include_equip = true,
      skill_name = fushi.name,
      prompt = "#ofl_tx__fushi_presume-discard:::" .. num,
    }) == 0 then
      room:changeMaxHp(player, -1)
    end
  end,
})

return fushi
