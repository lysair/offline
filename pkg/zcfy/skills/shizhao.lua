local shizhao = fk.CreateSkill {
  name = "sxfy__shizhao",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["sxfy__shizhao"] = "失诏",
  [":sxfy__shizhao"] = "锁定技，当你于回合外失去最后一张手牌后，你失去1点体力并摸两张牌。",
}

shizhao:addEffect(fk.AfterCardsMove, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(shizhao.name) and player:isKongcheng() and player.room.current ~= player then
      for _, move in ipairs(data) do
        if move.from == player then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand then
              return true
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:loseHp(player, 1, shizhao.name)
    if not player.dead then
      player:drawCards(2, shizhao.name)
    end
  end,
})

return shizhao
