local leyu = fk.CreateSkill {
  name = "ofl__leyu",
}

Fk:loadTranslationTable {
  ["ofl__leyu"] = "乐虞",
  [":ofl__leyu"] = "一名角色的回合开始时，你可以弃置三张牌令其进行判定，若结果不为<font color='red'>♥</font>，其跳过本回合的出牌阶段。",

  ["#ofl__leyu-invoke"] = "乐虞：弃三张牌令 %dest 判定，若不为<font color='red'>♥</font>，其跳过出牌阶段",
}

leyu:addEffect(fk.TurnStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(leyu.name) and not target.dead and
      #player:getCardIds("he") > 2
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local card = room:askToDiscard(player, {
      min_num = 3,
      max_num = 3,
      include_equip = true,
      skill_name = leyu.name,
      prompt = "#ofl__leyu-invoke::"..target.id,
      cancelable = true,
      skip = true,
    })
    if #card > 0 then
      event:setCostData(self, {tos = {target}, cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(event:getCostData(self).cards, leyu.name, player, player)
    if target.dead then return end
    local judge = {
      who = player,
      reason = leyu.name,
      pattern = ".|.|^heart",
    }
    room:judge(judge)
    if judge:matchPattern() then
      target:skip(Player.Play)
    end
  end,
})

return leyu
