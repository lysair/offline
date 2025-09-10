local xianlu = fk.CreateSkill {
  name = "sxfy__xianlu",
}

Fk:loadTranslationTable{
  ["sxfy__xianlu"] = "仙箓",
  [":sxfy__xianlu"] = "出牌阶段限一次，你可以弃置一名角色装备区内一张牌，若为红色，你将此牌当【乐不思蜀】置入你的判定区，对其造成1点伤害。",

  ["#sxfy__xianlu"] = "仙箓：弃置一名角色一张装备，若为红色则当【乐不思蜀】置入你的判定区并对其造成伤害",
}

xianlu:addEffect("active", {
  anim_type = "control",
  prompt = "#sxfy__xianlu",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(xianlu.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and #to_select:getCardIds("e") > 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local id = room:askToChooseCard(player, {
      target = target,
      flag = "e",
      skill_name = xianlu.name,
    })
    room:throwCard(id, xianlu.name, target, player)
    if player.dead then return end
    if Fk:getCardById(id).color == Card.Red then
      if table.contains(room.discard_pile, id) and
        not table.contains(player.sealedSlots, Player.JudgeSlot) and
        not player:hasDelayedTrick("indulgence") then
        local card = Fk:cloneCard("indulgence")
        card:addSubcard(id)
        player:addVirtualEquip(card)
        room:moveCardTo(card, Player.Judge, player, fk.ReasonJustMove, xianlu.name, nil, true, player)
      end
      if not target.dead then
        room:damage{
          from = player,
          to = target,
          damage = 1,
          skillName = xianlu.name,
        }
      end
    end
  end,
})

return xianlu
