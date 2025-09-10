local guisha = fk.CreateSkill {
  name = "ofl__guisha",
}

Fk:loadTranslationTable{
  ["ofl__guisha"] = "瑰杀",
  [":ofl__guisha"] = "当其他角色使用【杀】时，你可以弃置一张牌，令此【杀】不计入次数且造成伤害+1。",

  ["#ofl__guisha-invoke"] = "瑰杀：你可以弃一张牌，令 %dest 的【杀】不计入次数且伤害+1",
}

guisha:addEffect(fk.CardUsing, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(guisha.name) and
      data.card.trueName == "slash" and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local card = room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = guisha.name,
      cancelable = true,
      prompt = "#ofl__guisha-invoke::" .. target.id,
      skip = true,
    })
    if #card > 0 then
      event:setCostData(self, {tos = {target}, cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:throwCard(event:getCostData(self).cards, guisha.name, player, player)
    if not data.extraUse then
      target:addCardUseHistory(data.card.trueName, -1)
      data.extraUse = true
    end
    data.additionalDamage = (data.additionalDamage or 0) + 1
  end,
})

return guisha
