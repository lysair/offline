local wuji = fk.CreateSkill{
  name = "shzj_guansuo__wuji",
  tags = { Skill.Wake },
}

Fk:loadTranslationTable{
  ["shzj_guansuo__wuji"] = "武继",
  [":shzj_guansuo__wuji"] = "觉醒技，结束阶段，若你本回合造成了至少3点伤害，你加1点体力上限并回复1点体力，失去〖虎啸〗，"..
  "然后从游戏外获得【青龙偃月刀】或摸两张牌。",

  ["shzj_guansuo__wuji_blade"] = "获得【青龙偃月刀】",

  ["$shzj_guansuo__wuji1"] = "每逢佳节，报仇之心益切！",
  ["$shzj_guansuo__wuji2"] = "继父之武，承父之志！",
}

wuji:addEffect(fk.EventPhaseStart, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(wuji.name) and player.phase == Player.Finish and
      player:usedSkillTimes(wuji.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    local n = 0
    player.room.logic:getActualDamageEvents(1, function(e)
      local damage = e.data
      n = n + damage.damage
      return n > 2
    end, Player.HistoryTurn)
    return n > 2
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, 1)
    if player.dead then return end
    if player:isWounded() then
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = wuji.name,
      }
      if player.dead then return end
    end
    room:handleAddLoseSkills(player, "-shzj_guansuo__huxiao")
    if player.dead then return end
    local choice = room:askToChoice(player, {
      choices = {"shzj_guansuo__wuji_blade", "draw2"},
      skill_name = wuji.name,
    })
    if choice == "draw2" then
      player:drawCards(2, wuji.name)
    else
      local card = room:printCard("blade", Card.Spade, 5)
      room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonJustMove, wuji.name, nil, true, player)
    end
  end,
})

return wuji
