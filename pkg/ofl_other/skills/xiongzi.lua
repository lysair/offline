local xiongzi = fk.CreateSkill {
  name = "ofl__xiongzi"
}

Fk:loadTranslationTable{
  ['ofl__xiongzi'] = '雄姿',
  [':ofl__xiongzi'] = '锁定技，摸牌阶段，你额外摸X张牌；你的手牌上限+X（X为你当前体力值）。',
}

xiongzi:addEffect(fk.DrawNCards, {
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  on_use = function(self, event, target, player, data)
    data.n = data.n + player.hp
  end,
})

local xiongzi_maxcards = fk.CreateSkill{
  name = "#ofl__xiongzi_maxcards"
}

xiongzi_maxcards:addEffect('maxcards', {
  main_skill = xiongzi,
  correct_func = function (skill, player)
    if player:hasSkill(xiongzi.name) and player.hp > 0 then
      return player.hp
    end
  end,
})

return xiongzi
