local huntu = fk.CreateSkill{
  name = "ofl__huntu",
}

Fk:loadTranslationTable{
  ["ofl__huntu"] = "魂突",
  [":ofl__huntu"] = "每阶段限一次，当你于出牌阶段使用【杀】对目标角色造成伤害后，你可以对其使用一张【杀】。",

  ["#ofl__huntu-slash"] = "魂突：你可以对 %dest 使用一张【杀】",
}

huntu:addEffect(fk.Damage, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(huntu.name) and
      data.card and data.card.trueName == "slash" and not data.to.dead and
      player.room.logic:damageByCardEffect() and
      player.phase == Player.Play and player:usedSkillTimes(huntu.name, Player.HistoryPhase) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local use = room:askToUseCard(player, {
      skill_name = huntu.name,
      pattern = "slash",
      prompt = "#ofl__huntu-slash::" .. data.to.id,
      cancelable = true,
      extra_data = {
        exclusive_targets = {data.to.id},
        bypass_distances = true,
        bypass_times = true,
      }
    })
    if use then
      use.extraUse = true
      event:setCostData(self, {extra_data = use})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:useCard(event:getCostData(self).extra_data)
  end,
})

return huntu
