local huyi = fk.CreateSkill {
  name = "ofl_tx__huyi",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_tx__huyi"] = "狐疑",
  [":ofl_tx__huyi"] = "锁定技，其他角色的准备阶段，其需选择一项：1.交给你一半手牌（向下取整）；"..
  "2.你进行判定，若结果为：红色，本回合其使用牌不能指定除其以外的角色为目标；黑色，受到的伤害翻倍，直到你下回合结束。",

  ["#ofl_tx__huyi-ask"] = "狐疑：交给 %src %arg张手牌，否则其进行判定，根据颜色对你产生负面效果",
  ["@@ofl_tx__huyi_red-turn"] = "不能指定其他角色",
  ["@@ofl_tx__huyi_black"] = "受到伤害翻倍",
}

huyi:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(huyi.name) and target.phase == Player.Start and
      not target.dead
  end,
  on_cost = function (self, event, target, player, data)
    event:setCostData(self, {tos = {target}})
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if target:getHandcardNum() > 1 then
      local n = target:getHandcardNum() // 2
      local cards = room:askToCards(target, {
        min_num = n,
        max_num = n,
        include_equip = false,
        skill_name = huyi.name,
        prompt = "#ofl_tx__huyi-ask:"..player.id.."::"..n,
        cancelable = true,
      })
      if #cards > 0 then
        room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonGive, huyi.name, nil, false, target)
        return
      end
    end
    local judge = {
      who = player,
      reason = huyi.name,
      pattern = ".|.|^nocolor",
    }
    room:judge(judge)
    if target.dead then return end
    if judge.card then
      if judge.card.color == Card.Red then
        room:setPlayerMark(target, "@@ofl_tx__huyi_red-turn", 1)
      elseif judge.card.color == Card.Black and not player.dead then
        room:addTableMark(target, "@@ofl_tx__huyi_black", player.id)
      end
    end
  end,
})

huyi:addEffect("prohibit", {
  is_prohibited = function(self, from, to, card)
    return from and from:getMark("@@ofl_tx__huyi_red-turn") > 0 and card and from ~= to
  end,
})

huyi:addEffect(fk.DamageInflicted, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@@ofl_tx__huyi_black") ~= 0
  end,
  on_use = function(self, event, target, player, data)
    data:changeDamage(math.floor(data.damage * (2 ^ #player:getTableMark("@@ofl_tx__huyi_black") - 1)))
  end,
})

huyi:addEffect(fk.TurnEnd, {
  can_refresh = function(self, event, target, player, data)
    return target == player
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room.alive_players) do
      local mark = p:getMark("@@ofl_tx__huyi_black")
      if mark ~= 0 then
        for i = #mark, 1, -1 do
          if mark[i] == player.id then
            table.remove(mark, i)
          end
        end
        room:setPlayerMark(p, "@@ofl_tx__huyi_black", #mark == 0 and 0 or mark)
      end
    end
  end,
})

huyi:addLoseEffect(function (self, player, is_death)
    local room = player.room
    for _, p in ipairs(room.alive_players) do
      local mark = p:getMark("@@ofl_tx__huyi_black")
      if mark ~= 0 then
        for i = #mark, 1, -1 do
          if mark[i] == player.id then
            table.remove(mark, i)
          end
        end
        room:setPlayerMark(p, "@@ofl_tx__huyi_black", #mark == 0 and 0 or mark)
      end
    end
end)

return huyi
