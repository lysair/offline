local songsang = fk.CreateSkill {
  name = "qshm__songsang",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["qshm__songsang"] = "送丧",
  [":qshm__songsang"] = "限定技，一名角色死亡后，你可以加1点体力上限并回复1点体力，然后你获得〖展骥〗。",
}

songsang:addEffect(fk.Death, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(songsang.name) and player:usedSkillTimes(songsang.name, Player.HistoryGame) == 0
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
        skill_name = songsang.name,
      }
      if player.dead then return end
    end
    room:handleAddLoseSkills(player, "zhanji")
  end,
})

return songsang
