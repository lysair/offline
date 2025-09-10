local qiangong = fk.CreateSkill {
  name = "qiangong",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["qiangong"] = "迁宫",
  [":qiangong"] = "锁定技，当你失去场上的最后一张牌后，你摸一张牌。",
}

qiangong:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not (player:hasSkill(qiangong.name) and #player:getCardIds("ej") == 0) then return end
    for _, move in ipairs(data) do
      if move.from == player then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerEquip or info.fromArea == Card.PlayerJudge then
            return true
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, qiangong.name)
  end,
})

return qiangong