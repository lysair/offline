local duliangd = fk.CreateSkill {
  name = "sxfy__duliangd",
}

Fk:loadTranslationTable{
  ["sxfy__duliangd"] = "笃良",
  [":sxfy__duliangd"] = "当你受到伤害后，你可以摸一张牌，若你的手牌数等于体力值，你回复1点体力。",
}

duliangd:addEffect(fk.Damaged, {
  anim_type = "masochism",
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, duliangd.name)
    if not player.dead and player:getHandcardNum() == player.hp and player:isWounded() then
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = duliangd.name,
      }
    end
  end,
})

return duliangd
