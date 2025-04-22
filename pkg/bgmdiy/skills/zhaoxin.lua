local zhaoxin = fk.CreateSkill {
  name = "bgm__zhaoxin",
}

Fk:loadTranslationTable{
  ["bgm__zhaoxin"] = "昭心",
  [":bgm__zhaoxin"] = "摸牌阶段结束时，你可以展示所有手牌，然后视为使用一张无距离次数限制的【杀】。",
}

zhaoxin:addEffect(fk.EventPhaseEnd, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zhaoxin.name) and player.phase == Player.Draw and
      not player:isKongcheng()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:showCards(player:getCardIds("h"))
    if player.dead then return end
    room:askToUseVirtualCard(player, {
      skill_name = zhaoxin.name,
      name = "slash",
      cancelable = false,
      extra_data = {
        bypass_times = true,
        bypass_distances = true,
        extraUse = true,
      }
    })
  end,
})

return zhaoxin
