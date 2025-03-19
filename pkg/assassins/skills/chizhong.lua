local chizhong = fk.CreateSkill {
  name = "chizhong"
}

Fk:loadTranslationTable{
  ['chizhong'] = '持重',
  [':chizhong'] = '锁定技，你的手牌上限等于你的体力上限；有角色死亡时，你加1点体力上限。',
  ['$chizhong1'] = '遭逢翻覆，兵凶不休，独志不可夺。',
  ['$chizhong2'] = '秉节持重，大义在肩，唯百舍重茧。',
}

chizhong:addEffect(fk.Deathed, {
  can_trigger = function(self, event, target, player)
    return player:hasSkill(chizhong.name)
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    room:changeMaxHp(player, 1)
  end,
})

chizhong:addEffect('maxcards', {
  fixed_func = function(self, player)
    if player:hasSkill(chizhong.name) then
      return player.maxHp
    end
  end
})

return chizhong
