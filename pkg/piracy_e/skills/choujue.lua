local choujue = fk.CreateSkill {
  name = "ofl__choujue",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl__choujue"] = "仇决",
  [":ofl__choujue"] = "锁定技，当你杀死一名角色后，你加1点体力上限，摸两张牌，本回合〖却敌〗视为未发动过。",
}

choujue:addEffect(fk.Deathed, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(choujue.name) and data.killer == player
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:setSkillUseHistory("quedi", 0, Player.HistoryTurn)
    room:changeMaxHp(player, 1)
    if player.dead then return end
    player:drawCards(2, choujue.name)
  end,
})

return choujue
