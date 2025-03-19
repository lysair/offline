local shude = fk.CreateSkill {
  name = "shude"
}

Fk:loadTranslationTable{
  ['shude'] = '淑德',
  [':shude'] = '结束阶段开始时，你可以将手牌补至体力上限。',
}

shude:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(shude.name) and target == player and player.phase == Player.Finish and player:getHandcardNum() < player.maxHp
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(player.maxHp - player:getHandcardNum(), shude.name)
  end,
})

return shude
