local songci = fk.CreateSkill {
  name = "sxfy__songci",
}

Fk:loadTranslationTable{
  ["sxfy__songci"] = "颂词",
  [":sxfy__songci"] = "出牌阶段限一次，你可以：令一名手牌数大于体力值的角色弃置一张牌；或令一名手牌数小于体力值的角色摸一张牌。",

  ["#sxfy__songci"] = "颂词：令一名手牌数小于体力值的角色摸一张牌，或令一名手牌数大于体力值的角色弃一张牌",
}

songci:addEffect("active", {
  anim_type = "control",
  prompt = "#sxfy__songci",
  mute = true,
  card_num = 0,
  target_num = 1,
  can_use = function (self, player)
    return player:usedSkillTimes(songci.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_tip = function (self, player, to_select, selected, selected_cards, card, selectable, extra_data)
    if to_select:getHandcardNum() < to_select.hp then
      return { {content = "draw" , type = "normal"} }
    elseif to_select:getHandcardNum() > to_select.hp then
      return { {content = "discard", type = "warning"} }
    end
  end,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select:getHandcardNum() ~= to_select.hp
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    if target:getHandcardNum() < target.hp then
      player:broadcastSkillInvoke(songci.name, 1)
      target:drawCards(1, songci.name)
    else
      player:broadcastSkillInvoke(songci.name, 2)
      room:askToDiscard(target, {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        skill_name = songci.name,
        cancelable = false,
      })
    end
  end,
})

return songci
