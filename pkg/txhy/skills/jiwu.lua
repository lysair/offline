
local jiwu = fk.CreateSkill {
  name = "ofl_tx__jiwu",
}

Fk:loadTranslationTable{
  ["ofl_tx__jiwu"] = "极武",
  [":ofl_tx__jiwu"] = "当你使用【杀】或【决斗】时，你可以消耗至多3点<a href='os__baonue_href'>暴虐值</a>，令此牌增加等量的伤害基数值。",

  ["#ofl_tx__jiwu-invoke"] = "极武：你可以消耗暴虐值，令此%arg伤害增加！",
}

jiwu.os__baonue = true

jiwu:addEffect(fk.CardUsing, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jiwu.name) and
      table.contains({"slash", "duel"}, data.card.trueName) and player:getMark("@os__baonue") > 0
  end,
  on_cost = function (self,event, target, player, data)
    local room = player.room
    local n = room:askToNumber(player, {
      skill_name = jiwu.name,
      prompt = "#ofl_tx__jiwu-invoke:::"..data.card:toLogString(),
      min = 1,
      max = math.min(3, player:getMark("@os__baonue")),
      cancelable = true,
    })
    if n then
      event:setCostData(self, { choice = n })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = event:getCostData(self).choice
    room:removePlayerMark(player, "@os__baonue", n)
    data.additionalDamage = (data.additionalDamage or 0) + n
  end,
})

jiwu:addAcquireEffect(function(self, player)
  player.room:addSkill("#os__baonue_mark")
end)

return jiwu
