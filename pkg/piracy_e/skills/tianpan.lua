local tianpan = fk.CreateSkill {
  name = "ofl__tianpan",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl__tianpan"] = "天判",
  [":ofl__tianpan"] = "锁定技，当你的判定牌生效后，若结果：为♠，你获得此牌，然后你回复1点体力或加1点体力上限；不为♠，你失去1点体力或减1点体力上限。",

  ["ofl__tianpan1"] = "加1点体力上限",
}

tianpan:addEffect(fk.FinishJudge, {
  mute = true,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(tianpan.name)
    if data.card.suit == Card.Spade then
      room:notifySkillInvoked(player, tianpan.name, "support")
      if room:getCardArea(data.card) == Card.Processing then
        room:moveCardTo(data.card, Card.PlayerHand, player, fk.ReasonJustMove, tianpan.name, nil, true, player)
        if player.dead then return end
      end
      local choices = {"ofl__tianpan1"}
      if player:isWounded() then
        table.insert(choices, "recover")
      end
      local choice = room:askToChoice(player, {
        choices = choices,
        skill_name = tianpan.name,
      })
      if choice == "ofl__tianpan1" then
        room:changeMaxHp(player, 1)
      else
        room:recover{
          who = player,
          num = 1,
          recoverBy = player,
          skillName = tianpan.name,
        }
      end
    else
      room:notifySkillInvoked(player, tianpan.name, "negative")
      local choice = room:askToChoice(player, {
        choices = {"loseMaxHp", "loseHp"},
        skill_name = tianpan.name
      })
      if choice == "loseMaxHp" then
        room:changeMaxHp(player, -1)
      else
        room:loseHp(player, 1, tianpan.name)
      end
    end
  end,
})

return tianpan
