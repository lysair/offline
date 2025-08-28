local zhangu = fk.CreateSkill {
  name = "ofl__zhangu",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl__zhangu"] = "战孤",
  [":ofl__zhangu"] = "锁定技，回合开始时，若你体力上限大于1且没有手牌或装备区没有牌，你减1点体力上限，然后摸两张牌。",

  ["$ofl__zhangu1"] = "周身皆为壮士，纵无援军亦可胜之！",
  ["$ofl__zhangu2"] = "率十万之师，孤战群雄。",
}

zhangu:addEffect(fk.TurnStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zhangu.name) and player.maxHp > 1 and
      (player:isKongcheng() or #player:getCardIds("e") == 0)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, -1)
    if player.dead then return end
    player:drawCards(2, zhangu.name)
  end,
})

return zhangu
