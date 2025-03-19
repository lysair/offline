local insurrectionary = fk.CreateSkill {
  name = "insurrectionary&"
}

Fk:loadTranslationTable{
  ['insurrectionary&'] = '起义军',
  ['QuitInsurrectionary'] = '退出起义军并弃置所有手牌',
  ['@[:]insurrectionary'] = '',
  ['#QuitInsurrectionary'] = '%from 退出了起义军',
  [':insurrectionary&'] = '锁定技，<br>起义军出牌阶段使用【杀】次数上限+1。<br>起义军的回合结束时，若本回合未对起义军角色使用过【杀】且未对非起义军角色造成过伤害，需选择一项：1.失去起义军标记并弃置所有手牌；2.失去1点体力。<br>非起义军角色对起义军角色使用【杀】次数上限+1。',
}

insurrectionary:addEffect(fk.TurnEnd, {
  anim_type = "negative",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player)
    return target == player and IsInsurrectionary(player) and not player.dead and
      #player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
        local use = e.data[1]
        return use.from == player.id and use.card.trueName == "slash" and
          table.find(TargetGroup:getRealTargets(use.tos), function (id)
            return IsInsurrectionary(player.room:getPlayerById(id))
          end)
      end, Player.HistoryTurn) == 0 and
      #player.room.logic:getActualDamageEvents(1, function(e)
        local damage = e.data[1]
        return damage.from == player and not IsInsurrectionary(damage.to)
      end) == 0
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local choice = room:askToChoice(player, {
      choices = {"QuitInsurrectionary", "loseHp"},
      skill_name = insurrectionary.name
    })
    if choice == "QuitInsurrectionary" then
      room:setPlayerMark(player, "@!insurrectionary", 0)
      local tag = room:getBanner("insurrectionary") or {}
      table.removeOne(tag, player.id)
      if #tag == 0 then
        room:setBanner("insurrectionary", nil)
        room:setBanner("@[:]insurrectionary", nil)
      else
        room:setBanner("insurrectionary", tag)
      end
      room:sendLog{
        type = "#QuitInsurrectionary",
        from = player.id,
        toast = true,
      }
      room.logic:trigger("fk.QuitInsurrectionary", player, nil, false)
      if not player:isKongcheng() then
        player:throwAllCards("h")
      end
    else
      room:loseHp(player, 1, insurrectionary.name)
    end
  end,
})

insurrectionary:addEffect('targetmod', {
  frequency = Skill.Compulsory,
  residue_func = function(self, player, skillObj, scope, card, to)
    if Fk:currentRoom():getBanner("insurrectionary") and skillObj.trueName == "slash_skill" and scope == Player.HistoryPhase then
      if IsInsurrectionary(player) then
        return 1
      elseif IsInsurrectionary(to) then
        return 1
      end
    end
  end,
})

return insurrectionary
