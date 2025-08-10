local shanwu = fk.CreateSkill{
  name = "ofl__shanwu",
}

Fk:loadTranslationTable{
  ["ofl__shanwu"] = "闪舞",
  [":ofl__shanwu"] = "当其他角色成为【杀】的目标时，你可以弃置一张【闪】，取消之。",

  ["#ofl__shanwu-invoke"] = "闪舞：你可以弃置一张【闪】，取消此%arg",
}

shanwu:addEffect(fk.TargetConfirming, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(shanwu.name) and
      data.card.trueName == "slash" and not player:isKongcheng()
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local card = room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = shanwu.name,
      pattern = "jink",
      prompt = "#ofl__shanwu-invoke:::"..data.card:toLogString(),
      cancelable = true,
      skip = true,
    })
    if #card > 0 then
      event:setCostData(self, {cards = card})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    player.room:throwCard(event:getCostData(self).cards, shanwu.name, player, player)
    data:cancelAllTarget()
  end,
})

return shanwu
