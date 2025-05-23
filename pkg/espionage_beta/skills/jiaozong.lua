local jiaozong = fk.CreateSkill {
  name = "jiaozong",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["jiaozong"] = "骄纵",
  [":jiaozong"] = "锁定技，其他角色于其出牌阶段使用的第一张红色牌目标须为你，且无距离限制。",
}

jiaozong:addEffect("prohibit", {
  is_prohibited = function(self, from, to, card)
    if card and from.phase == Player.Play and card.color == Card.Red and from:getMark("jiaozong-phase") == 0 then
      return table.find(Fk:currentRoom().alive_players, function(p)
        return p:hasSkill(jiaozong.name) and p ~= from and p ~= to
      end)
    end
  end,
  prohibit_use = function(self, player, card)
    if card and player.phase == Player.Play and card.color == Card.Red and player:getMark("jiaozong-phase") == 0 then
      return table.find(Fk:currentRoom().alive_players, function(p)
        return p:hasSkill(jiaozong.name) and p ~= player
      end) and card.skill.min_target_num == 0 and not card.multiple_targets
    end
  end,
})

jiaozong:addEffect("targetmod", {
  bypass_distances = function(self, player, skill_name, card, to)
    return to:hasSkill(jiaozong.name) and player.phase == Player.Play and player:getMark("jiaozong-phase") == 0 and
      card and card.color == Card.Red
  end,
})

jiaozong:addEffect(fk.AfterCardUseDeclared, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player.phase == Player.Play and data.card.color == Card.Red
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "jiaozong-phase", 1)
  end,
})

jiaozong:addAcquireEffect(function (self, player, is_start)
  if not is_start then
    local room = player.room
    if player.phase ~= Player.Play and room.current.phase == Player.Play then
      room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
        local use = e.data
        if use.from == room.current and use.card.color == Card.Red then
          room:setPlayerMark(room.current, "jiaozong-phase", 1)
          return true
        end
      end, Player.HistoryPhase)
    end
  end
end)

return jiaozong
