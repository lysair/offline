local fuwei = fk.CreateSkill {
  name = "fuwei",
}

Fk:loadTranslationTable{
  ["fuwei"] = "扶危",
  [":fuwei"] = "每回合限一次，当一号位角色或刘备受到伤害后，你可以交给其至多X张牌，然后你可以对伤害来源依次使用至多X张【杀】（X为伤害值）。",

  ["#fuwei1-give"] = "扶危：你可以交给 %dest 至多%arg张牌，然后可以对 %src 使用至多%arg张【杀】",
  ["#fuwei2-give"] = "扶危：你可以交给 %dest 至多%arg张牌",
  ["#fuwei-slash"] = "扶危：你可以对 %dest 使用【杀】（第%arg张，共%arg2张）",
}

fuwei:addEffect(fk.Damaged, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(fuwei.name) and
      (target.seat == 1 or
      string.find(Fk:translate(target.general, "zh_CN"), "刘备") or
      string.find(Fk:translate(target.deputyGeneral, "zh_CN"), "刘备")) and
      not player:isNude() and player:usedSkillTimes(fuwei.name, Player.HistoryTurn) == 0 and
      (target ~= player or (data.from and not data.from.dead and data.from ~= player))
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local prompt
    if data.from and not data.from.dead and data.from ~= player then
      prompt = "#fuwei1-give:"..data.from.id..":"..target.id..":"..data.damage
    else
      prompt = "#fuwei2-give::"..target.id..":"..data.damage
    end
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = data.damage,
      include_equip = true,
      skill_name = fuwei.name,
      prompt = prompt,
      cancelable = true,
    })
    if #cards > 0 then
      event:setCostData(self, {tos = {target}, cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if target ~= player then
      room:moveCardTo(event:getCostData(self).cards, Card.PlayerHand, target, fk.ReasonGive, fuwei.name, nil, false, player)
    end
    if data.from and data.from ~= player then
      local n = data.damage
      for i = 1, n, 1 do
        if player.dead or data.from.dead then return end
        local use = room:askToUseCard(player, {
          skill_name = fuwei.name,
          pattern = "slash",
          prompt = "#fuwei-slash::"..data.from.id..":"..i..":"..n,
          extra_data = {
            bypass_distances = true,
            bypass_times = true,
            exclusive_targets = {data.from.id},
          }
        })
        if use then
          use.extraUse = true
          room:useCard(use)
        else
          return
        end
      end
    end
  end,
})

return fuwei
