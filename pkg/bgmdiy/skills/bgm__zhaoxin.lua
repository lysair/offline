local bgm__zhaoxin = fk.CreateSkill {
  name = "bgm__zhaoxin"
}

Fk:loadTranslationTable{
  ['bgm__zhaoxin'] = '昭心',
  [':bgm__zhaoxin'] = '摸牌阶段结束时，你可以展示所有手牌：若如此做，视为你使用一张【杀】。',
}

bgm__zhaoxin:addEffect(fk.EventPhaseEnd, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and player.phase == Player.Draw and not player:isKongcheng()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:showCards(player.player_cards[Player.Hand])
    U.askToUseVirtualCard(room, player, {
      pattern = "slash",
      skill_name = skill.name,
      cancelable = false,
      extra_data = true,
      bypass_times = true,
      bypass_distances = true
    })
  end,
})

return bgm__zhaoxin
