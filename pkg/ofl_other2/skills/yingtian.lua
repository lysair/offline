local yingtian = fk.CreateSkill {
  name = "yingtian"
}

Fk:loadTranslationTable{
  ['yingtian'] = '应天',
  [':yingtian'] = '觉醒技，一名角色死亡后，若场上势力数不大于2，你获得〖鬼才〗〖完杀〗〖连破〗，本局游戏使用牌无距离限制，失去〖英猷〗。',
}

yingtian:addEffect(fk.Deathed, {
  anim_type = "special",
  frequency = Skill.Wake,
  can_trigger = function (self, event, target, player)
    return player:hasSkill(yingtian.name) and player:usedSkillTimes(yingtian.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player)
    local kingdoms = {}
    for _, p in ipairs(player.room.alive_players) do
      table.insertIfNeed(kingdoms, p.kingdom)
    end
    return #kingdoms < 3
  end,
  on_use = function (self, event, target, player)
    player.room:handleAddLoseSkills(player, "ex__guicai|wansha|lianpo|-yingyou", nil, true, false)
  end,
})

yingtian:addEffect('targetmod', {
  bypass_distances = function(self, player, skill, card)
    return card and player:usedSkillTimes(yingtian.name, Player.HistoryGame) > 0
  end,
})

return yingtian
