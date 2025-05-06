local guibei = fk.CreateSkill {
  name = "guibei",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["guibei"] = "贵卑",
  [":guibei"] = "锁定技，游戏开始时，你摸四张牌，然后和一号位的上家交换座次。",
}

guibei:addEffect(fk.GameStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(guibei.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(4, guibei.name)
    if not player.dead then
      local to = room:getPlayerBySeat(1):getLastAlive()
      local yes = player == room.current
      if to ~= player then
        room:swapSeat(player, to)
        if yes then
          room:setCurrent(to)
        end
      end
    end
  end,
})

return guibei
