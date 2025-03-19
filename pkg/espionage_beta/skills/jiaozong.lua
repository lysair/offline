local jiaozong = fk.CreateSkill {
  name = "jiaozong"
}

Fk:loadTranslationTable{
  ['jiaozong'] = '骄纵',
  [':jiaozong'] = '锁定技，其他角色于其出牌阶段使用的第一张红色牌目标须为你，且无距离限制。',
}

jiaozong:addEffect('prohibit', {
  frequency = Skill.Compulsory,
  is_prohibited = function(self, from, to, card)
    if from.phase == Player.Play and card.color == Card.Red and from:getMark("jiaozong-phase") == 0 then
      return table.find(Fk:currentRoom().alive_players, function(p)
        return p:hasSkill(jiaozong.name) and p ~= from and p ~= to
      end)--桃子无中、装备等需要特判
    end
  end,
  prohibit_use = function(self, player, card)
    if player.phase == Player.Play and card.color == Card.Red and player:getMark("jiaozong-phase") == 0 then
      return table.find(Fk:currentRoom().alive_players, function(p) return p:hasSkill(jiaozong.name) and p ~= player end) and
        (card.type == Card.TypeEquip or table.contains({"peach", "ex_nihilo", "lightning", "analeptic", "foresight"}, card.trueName))
    end
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

jiaozong:addEffect('targetmod', {
  bypass_distances = function(self, player, skill_name, card, to)
    return to:hasSkill(jiaozong.name) and player.phase == Player.Play and player:getMark("jiaozong-phase") == 0 and
      card and card.color == Card.Red
  end,
})

return jiaozong
