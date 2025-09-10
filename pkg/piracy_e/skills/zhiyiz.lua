local zhiyiz = fk.CreateSkill {
  name = "zhiyiz",
}

Fk:loadTranslationTable{
  ["zhiyiz"] = "志异",
  [":zhiyiz"] = "出牌阶段限一次，你可以令一名角色摸一张牌，然后你对其造成1点伤害。",

  ["#zhiyiz"] = "志异：令一名角色摸一张牌，然后对其造成1点伤害。",

  ["$zhiyiz1"] = "鸢飞戾天，鱼跃于渊。君子之志，岂在福禄黄白？",
  ["$zhiyiz2"] = "玉山候王母，珠庭谒老君，宁作蜉蝣子，此生逐功业。",
}

zhiyiz:addEffect("active", {
  anim_type = "offensive",
  prompt = "#zhiyiz",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(zhiyiz.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    target:drawCards(1, zhiyiz.name)
    if not target.dead then
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skill_name = zhiyiz.name,
      }
    end
  end,
})

return zhiyiz
