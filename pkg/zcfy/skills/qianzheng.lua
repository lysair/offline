local qianzheng = fk.CreateSkill {
  name = "sxfy__qianzheng",
}

Fk:loadTranslationTable{
  ["sxfy__qianzheng"] = "愆正",
  [":sxfy__qianzheng"] = "每回合限一次，当你成为其他角色使用【杀】的目标时，你可以重铸两张手牌。",

  ["#sxfy__qianzheng-invoke"] = "愆正：你可以重铸两张手牌",
}

qianzheng:addEffect(fk.TargetConfirming, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(qianzheng.name) and
      data.from ~= player and data.card.trueName == "slash" and
      player:getHandcardNum() > 1 and
      player:usedSkillTimes(qianzheng.name, Player.HistoryTurn) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = room:askToCards(player, {
      skill_name = qianzheng.name,
      min_num = 2,
      max_num = 2,
      include_equip = false,
      prompt = "#sxfy__qianzheng-invoke",
      cancelable = true,
    })
    if #cards == 2 then
      event:setCostData(self, {cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:recastCard(event:getCostData(self).cards, player, qianzheng.name)
  end,
})

return qianzheng
