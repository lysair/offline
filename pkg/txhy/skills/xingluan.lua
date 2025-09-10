local xingluan = fk.CreateSkill {
  name = "ofl_tx__xingluan",
}

Fk:loadTranslationTable{
  ["ofl_tx__xingluan"] = "兴乱",
  [":ofl_tx__xingluan"] = "每回合限一次，当你使用或打出牌结算结束后，你可以从牌堆中获得一张点数为6的牌。",

  ["$ofl_tx__xingluan1"] = "大兴兵争，长安当乱。",
  ["$ofl_tx__xingluan2"] = "勇猛兴军，乱世当立。",
}

local spec = {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xingluan.name) and
      player:usedSkillTimes(xingluan.name, Player.HistoryTurn) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = room:getCardsFromPileByRule(".|6")
    if #card > 0 then
      room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonJustMove, xingluan.name, nil, false, player)
    end
  end,
}
xingluan:addEffect(fk.CardUseFinished, spec)
xingluan:addEffect(fk.CardRespondFinished, spec)

return xingluan
