local miaojian = fk.CreateSkill {
  name = "miaojian"
}

Fk:loadTranslationTable{
  ['miaojian'] = '妙剑',
  ['@miaojian'] = '妙剑',
  ['#miaojian1'] = '妙剑：你可以将【杀】当刺【杀】、锦囊牌当【无中生有】使用',
  ['status2'] = '二阶',
  ['#miaojian2'] = '妙剑：你可以将基本牌当刺【杀】、非基本牌当【无中生有】使用',
  ['status3'] = '三阶',
  ['#miaojian3'] = '妙剑：你可以视为使用一张刺【杀】或【无中生有】',
  [':miaojian'] = '出牌阶段限一次，你可以将【杀】当刺【杀】、锦囊牌当【无中生有】使用。<br>二阶：出牌阶段限一次，你可以将基本牌当刺【杀】、非基本牌当【无中生有】使用。<br>三阶：出牌阶段限一次，你可以视为使用一张刺【杀】或【无中生有】。',
  ['$miaojian1'] = '谨以三尺玄锋，代天行化，布令宣威。',
  ['$miaojian2'] = '布天罡，踏北斗，有秽皆除，无妖不斩。',
}

miaojian:addEffect('viewas', {
  prompt = function(self, player)
    if player:getMark("@miaojian") == 0 then
      return "#miaojian1"
    elseif player:getMark("@miaojian") == "status2" then
      return "#miaojian2"
    elseif player:getMark("@miaojian") == "status3" then
      return "#miaojian3"
    end
    return ""
  end,
  interaction = function(self, player)
    return U.CardNameBox {choices = {"stab__slash", "ex_nihilo"}}
  end,
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    if #selected == 0 then
      local card = Fk:getCardById(to_select)
      if player:getMark("@miaojian") == 0 then
        if skill.interaction.data == "stab__slash" then
          return card.trueName == "slash"
        elseif skill.interaction.data == "ex_nihilo" then
          return card.type == Card.TypeTrick
        end
      elseif player:getMark("@miaojian") == "status2" then
        if skill.interaction.data == "stab__slash" then
          return card.type == Card.TypeBasic
        elseif skill.interaction.data == "ex_nihilo" then
          return card.type ~= Card.TypeBasic
        end
      elseif player:getMark("@miaojian") == "status3" then
        return false
      end
    end
  end,
  view_as = function(self, player, cards)
    if not skill.interaction.data then return end
    local card = Fk:cloneCard(skill.interaction.data)
    if player:getMark("@miaojian") == 0 or player:getMark("@miaojian") == "status2" then
      if #cards ~= 1 then return end
      card:addSubcard(cards[1])
    end
    card.skillName = miaojian.name
    return card
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(miaojian.name, Player.HistoryPhase) == 0
  end,
})

return miaojian
