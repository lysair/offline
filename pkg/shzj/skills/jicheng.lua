local jicheng = fk.CreateSkill {
  name = "jicheng",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["jicheng"] = "计成",
  [":jicheng"] = "限定技，当你受到普通锦囊牌的伤害后，若你的体力值不大于2，你可以回复1点体力或摸两张牌。",
}

jicheng:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jicheng.name) and
      player:usedSkillTimes(jicheng.name, Player.HistoryGame) == 0 and
      data.card and data.card.type == Card.TypeTrick and player.hp < 3
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choices = {"draw2"}
    if player:isWounded() then
      table.insert(choices, "recover")
    end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = jicheng.name,
    })
    if choice == "draw2" then
      player:drawCards(2, jicheng.name)
    else
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = jicheng.name,
      }
    end
  end,
})

return jicheng
