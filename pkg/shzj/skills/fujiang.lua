local fujiang = fk.CreateSkill{
  name = "fujiang",
}

Fk:loadTranslationTable{
  ["fujiang"] = "浮江",
  [":fujiang"] = "每回合限一次，当一名角色受到伤害后，你可以令其上家和下家依次可以对其使用一张【杀】。",

  ["#fujiang-invoke"] = "浮江：你可以令 %dest 的上家和下家可以对其使用【杀】！",
  ["#fujiang-slash"] = "浮江：你可以对 %dest 使用一张【杀】",
}

fujiang:addEffect(fk.Damaged, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(fujiang.name) and not target.dead and
      player:usedSkillTimes(fujiang.name, Player.HistoryTurn) == 0 and
      (target:getNextAlive() ~= target or target:getLastAlive() ~= target)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = fujiang.name,
      prompt = "#fujiang-invoke::"..target.id,
    }) then
      local tos = {}
      if target:getNextAlive() ~= target then
        table.insert(tos, target:getNextAlive())
      end
      if target:getLastAlive() ~= target then
        table.insertIfNeed(tos, target:getLastAlive())
      end
      room:sortByAction(tos)
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local tos = table.simpleClone(event:getCostData(self).tos)
    for _, to in ipairs(tos) do
      if target.dead then return end
      if not to.dead then
        local use = room:askToUseCard(to, {
          skill_name = fujiang.name,
          pattern = "slash",
          prompt = "#fujiang-slash::"..target.id,
          extra_data = {
            bypass_times = true,
            exclusive_targets = {target.id},
          }
        })
        if use then
          use.extraUse = true
          room:useCard(use)
        end
      end
    end
  end,
})

return fujiang
