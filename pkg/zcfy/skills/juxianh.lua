local juxianh = fk.CreateSkill {
  name = "juxianh",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["juxianh"] = "据险",
  [":juxianh"] = "锁定技，当其他角色获得你的牌时，防止之。",
}

juxianh:addEffect(fk.BeforeCardsMove, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(juxianh.name) then
      for _, move in ipairs(data) do
        if move.from == player and move.moveReason == fk.ReasonPrey and move.proposer ~= player then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
              return true
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local ids = {}
    for _, move in ipairs(data) do
        if move.from == player and move.moveReason == fk.ReasonPrey and move.proposer ~= player then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
            table.insert(ids, info.cardId)
          end
        end
      end
    end
    room:cancelMove(data, ids)
  end,
})

return juxianh