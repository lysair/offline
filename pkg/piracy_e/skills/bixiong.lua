local bixiong = fk.CreateSkill {
  name = "ofl__bixiong",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["ofl__bixiong"] = "避凶",
  [":ofl__bixiong"] = "限定技，出牌阶段，你可以弃置两张手牌，加1点体力上限。",

  ["#ofl__bixiong"] = "避凶：弃置两张手牌，加1点体力上限",
}

bixiong:addEffect("active", {
  anim_type = "support",
  prompt = "#ofl__bixiong",
  card_num = 2,
  target_num = 0,
  can_use = function (self, player)
    return player:usedSkillTimes(bixiong.name, Player.HistoryGame) == 0
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected < 2 and not player:prohibitDiscard(to_select) and
      table.contains(player:getCardIds("h"), to_select)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    room:throwCard(effect.cards, bixiong.name, player, player)
    if not player.dead then
      room:changeMaxHp(player, 1)
    end
  end,
})

return bixiong
