local tuicheng = fk.CreateSkill {
  name = "tuicheng"
}

Fk:loadTranslationTable{
  ['tuicheng'] = '推诚',
  ['#tuicheng'] = '推诚：你可以失去1点体力，视为使用一张【推心置腹】',
  [':tuicheng'] = '你可以失去1点体力，视为使用一张【推心置腹】。',
}

tuicheng:addEffect('viewas', {
  anim_type = "control",
  pattern = "sincere_treat",
  prompt = "#tuicheng",
  card_filter = Util.FalseFunc,
  view_as = function(self, player, cards)
    local card = Fk:cloneCard("sincere_treat")
    card.skillName = tuicheng.name
    return card
  end,
  before_use = function(self, player, use)
    player.room:loseHp(player, 1, tuicheng.name)
  end,
})

return tuicheng
