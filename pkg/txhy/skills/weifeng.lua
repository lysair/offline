local weifeng = fk.CreateSkill {
  name = "ofl_tx__weifeng",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_tx__weifeng"] = "威风",
  [":ofl_tx__weifeng"] = "锁定技，当你于出牌阶段使用伤害类牌结算结束后，你选择其中一名没有“惧”的其他目标角色，令其获得此牌名的“惧”标记。"..
  "有“惧”的角色受到伤害时，移除“惧”并执行效果：若造成伤害的牌名与“惧”相同，则此伤害+1；若不同，你获得其一张牌。",

  ["$ofl_tx__weifeng1"] = "广散惧义，尽泄敌之斗志。",
  ["$ofl_tx__weifeng2"] = "若尔等惧我，自当卷甲以降。",
}

weifeng:addLoseEffect(function (self, player)
  local room = player.room
  for _, p in ipairs(room:getOtherPlayers(player, false)) do
    room:setPlayerMark(p, "@weifeng", 0)
  end
end)

weifeng:addEffect(fk.CardUseFinished, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(weifeng.name) and player.phase == Player.Play and
      data.card.is_damage_card and
      table.find(data.tos, function(p)
        return p ~= player and not p.dead and p:getMark(weifeng.name) == 0
      end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(data.tos, function(p)
      return p ~= player and not p.dead and p:getMark(weifeng.name) == 0
    end)
    if #targets == 1 then
      room:setPlayerMark(targets[1], "@weifeng", data.card.trueName)
    elseif #targets > 1 then
      local to = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 1,
        targets = targets,
        skill_name = weifeng.name,
        prompt = "#weifeng-choose",
        cancelable = false,
      })[1]
      room:setPlayerMark(to, "@weifeng", data.card.trueName)
    end
  end,
})

weifeng:addEffect(fk.DamageInflicted, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(weifeng.name) and target:getMark("@weifeng") ~= 0
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:doIndicate(player, {target})
    if data.card and data.card.trueName == target:getMark("@weifeng") then
      data:changeDamage(1)
    elseif not target:isNude() then
      local id = room:askToChooseCard(player, {
        target = target,
        flag = "he",
        skill_name = "weifeng",
        prompt = "#weifeng-prey::"..player.id
      })
      room:obtainCard(player, id, false, fk.ReasonPrey, player, weifeng.name)
    end
    room:setPlayerMark(target, "@weifeng", 0)
  end,
})

return weifeng
