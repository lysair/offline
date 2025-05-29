local miaojian = fk.CreateSkill {
  name = "ofl__miaojian",
  dynamic_desc = function (self, player, lang)
    if player:getMark("ofl__miaojian-turn") > 0 then
      return "ofl__miaojian_update"
    else
      return "ofl__miaojian0"
    end
  end,
}

Fk:loadTranslationTable{
  ["ofl__miaojian"] = "妙剑",
  [":ofl__miaojian"] = "出牌阶段限一次，你可以将基本牌当刺【杀】（无次数限制）、非基本牌当【无中生有】使用。<br>"..
  "修改后：出牌阶段限一次，你可以视为使用一张刺【杀】或【无中生有】。",

  [":ofl__miaojian0"] = "出牌阶段限一次，你可以将基本牌当刺【杀】（无次数限制）、非基本牌当【无中生有】使用。",
  [":ofl__miaojian_update"] = "出牌阶段限一次，你可以视为使用一张刺【杀】或【无中生有】。",

  ["#ofl__miaojian"] = "妙剑：你可以将基本牌当刺【杀】、非基本牌当【无中生有】使用",
  ["#ofl__miaojian_update"] = "妙剑：你可以视为使用一张刺【杀】或【无中生有】",

  ["$ofl__miaojian1"] = "剑斩魔头，观万灵慑服，群妖束首！",
  ["$ofl__miaojian2"] = "一人一剑，往荡平魔窟，再肃人间！",
}

local U = require "packages/utility/utility"

miaojian:addEffect("viewas", {
  prompt = function(self, player)
    if player:getMark("ofl__miaojian-turn") > 0 then
      return "#ofl__miaojian_update"
    else
      return "#ofl__miaojian"
    end
  end,
  interaction = function(self, player)
    return U.CardNameBox {choices = {"stab__slash", "ex_nihilo"}}
  end,
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    if #selected == 0 and player:getMark("ofl__miaojian-turn") == 0 then
      local card = Fk:getCardById(to_select)
      if self.interaction.data == "stab__slash" then
        return card.type == Card.TypeBasic
      elseif self.interaction.data == "ex_nihilo" then
        return card.type ~= Card.TypeBasic
      end
    end
  end,
  view_as = function(self, player, cards)
    if not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    if player:getMark("ofl__miaojian-turn") == 0 then
      if #cards ~= 1 then return end
      card:addSubcard(cards[1])
    end
    card.skillName = miaojian.name
    return card
  end,
  before_use = function (self, player, use)
    use.extraUse = true
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(miaojian.name, Player.HistoryPhase) == 0
  end,
})

miaojian:addEffect("targetmod", {
  bypass_times = function (self, player, skill, scope, card, to)
    return card and table.contains(card.skillNames, miaojian.name)
  end,
})

return miaojian
