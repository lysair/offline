local tianzi = fk.CreateSkill {
  name = "ofl_tx__tianzi",
  tags = { Skill.Spirited },
}

Fk:loadTranslationTable{
  ["ofl_tx__tianzi"] = "天姿",
  [":ofl_tx__tianzi"] = "<a href='#SpiritedSkillDesc'>昂扬技</a>，当你受到伤害后或出牌阶段开始时，你可以选择一名其他角色并进行判定，"..
  "若结果为：红色，其跳过下个出牌阶段；黑色，你获得其所有手牌。<a href='#SpiritedSkillDesc'>激昂</a>：其他角色跳过阶段后。",

  ["#ofl_tx__tianzi-choose"] = "天姿：选择一名角色并判定，红色其跳过下个出牌阶段，黑色你获得其所有手牌",
  ["@@ofl_tx__tianzi"] = "天姿",
  ["@@ofl_tx__tianzi_skip"] = "跳过出牌阶段",
}

local spec = {
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player, false),
      skill_name = tianzi.name,
      prompt = "#ofl_tx__tianzi-choose",
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@ofl_tx__tianzi", 1)
    local to = event:getCostData(self).tos[1]
    local judge = {
      who = player,
      reason = tianzi.name,
      pattern = ".|.|^nocolor",
    }
    room:judge(judge)
    if to.dead then return end
    if judge.card then
      if judge.card.color == Card.Red then
        if not to.dead then
          room:setPlayerMark(to, "@@ofl_tx__tianzi_skip", 1)
        end
      elseif judge.card.color == Card.Black and not to:isKongcheng() then
        room:moveCardTo(to:getCardIds("h"), Card.PlayerHand, player, fk.ReasonPrey, tianzi.name, nil, false, player)
      end
    end
  end,
}

tianzi:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(tianzi.name) and player.phase == Player.Play and
      #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = spec.on_cost,
  on_use = spec.on_use,
})

tianzi:addEffect(fk.EventPhaseChanging, {
  can_refresh = function(self, event, target, player, data)
    return target == player and data.phase == Player.Play and
      player:getMark("@@ofl_tx__tianzi_skip") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@ofl_tx__tianzi_skip", 0)
    data.skipped = true
  end,
})

tianzi:addEffect(fk.EventPhaseSkipped, {
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@@ofl_tx__tianzi") > 0 and target ~= player
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@ofl_tx__tianzi", 0)
  end,
})

tianzi:addEffect("invalidity", {
  invalidity_func = function (self, from, skill)
    return from:getMark("@@ofl_tx__tianzi") > 0 and skill.name == tianzi.name
  end,
})

return tianzi
