local huairou = fk.CreateSkill {
  name = "shzj_juedai__huairou",
}

Fk:loadTranslationTable{
  ["shzj_juedai__huairou"] = "怀柔",
  [":shzj_juedai__huairou"] = "出牌阶段，你可以重铸一张装备牌，若为本回合首次，你可以视为使用一张普通锦囊牌。",

  ["#shzj_juedai__huairou"] = "怀柔：你可以重铸装备牌",
  ["#shzj_juedai__huairou-use"] = "怀柔：你可以视为使用一张普通锦囊牌",

  ["$shzj_juedai__huairou1"] = "彰信行仁爱之德，怀万民生息之心！",
  ["$shzj_juedai__huairou2"] = "战可保一时之利，息方为万世之功！",
}

huairou:addEffect("active", {
  anim_type = "drawcard",
  prompt = "#shzj_juedai__huairou",
  card_num = 1,
  target_num = 0,
  can_use = Util.TrueFunc,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).type == Card.TypeEquip
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    room:recastCard(effect.cards, player, huairou.name)
    if player:usedSkillTimes(huairou.name, Player.HistoryPhase) == 1 and not player.dead then
      room:askToUseVirtualCard(player, {
        name = player:getViewAsCardNames(huairou.name, Fk:getAllCardNames("t")),
        skill_name = huairou.name,
        prompt = "#shzj_juedai__huairou-use",
        cancelable = true,
      })
    end
  end,
})

return huairou
