local shicha = fk.CreateSkill {
  name = "shicha"
}

Fk:loadTranslationTable{
  ['shicha'] = '失察',
  ['tuicheng'] = '推诚',
  ['yaoling'] = '耀令',
  [':shicha'] = '锁定技，弃牌阶段开始时，若你本回合〖推诚〗和〖耀令〗均未发动，你本回合手牌上限改为1。',
}

shicha:addEffect(fk.EventPhaseStart, {
  anim_type = "negative",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shicha.name) and player.phase == Player.Discard and
      player:usedSkillTimes("tuicheng", Player.HistoryTurn) == 0 and player:usedSkillTimes("yaoling", Player.HistoryTurn) == 0
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "shicha-turn", 1)
  end,
})

shicha:addEffect('maxcards', {
  fixed_func = function(self, player)
    if player:getMark("shicha-turn") > 0 then
      return 1
    end
  end
})

return shicha
  ```

