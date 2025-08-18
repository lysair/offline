local luanji = fk.CreateSkill {
  name = "ofl_mou__luanji",
}

Fk:loadTranslationTable{
  ["ofl_mou__luanji"] = "乱击",
  [":ofl_mou__luanji"] = "出牌阶段限一次，你可以将两张手牌当【万箭齐发】使用。当其他角色打出【闪】响应你使用的【万箭齐发】时，"..
  "若你的手牌数小于体力值且小于其手牌数，你摸一张牌。",

  ["#ofl_mou__luanji"] = "乱击：你可以将两张手牌当【万箭齐发】使用",

  ["$ofl_mou__luanji1"] = "翦公孙，平夷患，起高橹，靖四州！",
  ["$ofl_mou__luanji2"] = "乱箭之下，尽显吾袁门之威！",
}

luanji:addEffect("viewas", {
  anim_type = "offensive",
  prompt = "#ofl_mou__luanji",
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected < 2 and table.contains(player:getHandlyIds(), to_select)
  end,
  view_as = function(self, player, cards)
    if #cards ~= 2 then return end
    local card = Fk:cloneCard("archery_attack")
    card:addSubcards(cards)
    return card
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(luanji.name, Player.HistoryPhase) == 0
  end,
})

luanji:addEffect(fk.CardResponding, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(luanji.name) and target ~= player and data.card.name == "jink" and
      data.responseToEvent and data.responseToEvent.from == player and
      data.responseToEvent.card.trueName == "archery_attack" and
      player:getHandcardNum() < player.hp and player:getHandcardNum() < target:getHandcardNum()
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, luanji.name)
  end,
})

luanji:addAI(nil, "vs_skill")

return luanji
