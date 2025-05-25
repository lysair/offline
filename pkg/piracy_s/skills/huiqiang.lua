local huiqiang = fk.CreateSkill{
  name = "ofl__huiqiang",
}

Fk:loadTranslationTable{
  ["ofl__huiqiang"] = "回枪",
  [":ofl__huiqiang"] = "当你使用【杀】被目标角色使用【闪】抵消后，你可以对其使用一张【杀】。",

  ["#ofl__huiqiang-slash"] = "回枪：你可以对 %dest 使用一张【杀】",
}

huiqiang:addEffect(fk.CardEffectCancelledOut, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(huiqiang.name) and
      data.card.trueName == "slash" and not data.to.dead
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local use = room:askToUseCard(player, {
      skill_name = huiqiang.name,
      pattern = "slash",
      prompt = "#ofl__huiqiang-slash::" .. data.to.id,
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

return huiqiang
