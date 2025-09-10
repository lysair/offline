local mumu = fk.CreateSkill {
  name = "sxfy__mumu",
}

Fk:loadTranslationTable{
  ["sxfy__mumu"] = "穆穆",
  [":sxfy__mumu"] = "准备阶段，你可以弃置一张手牌，然后移动场上一张装备牌。",

  ["#sxfy__mumu-invoke"] = "穆穆：你可以弃置一张手牌，然后移动场上一张装备牌",
  ["#sxfy__mumu-move"] = "穆穆：移动场上一张装备牌",
}

mumu:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(mumu.name) and player.phase == Player.Start and
      not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local card = room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = mumu.name,
      prompt = "#sxfy__mumu-invoke",
      cancelable = true,
      skip = true,
    })
    if #card > 0 then
      event:setCostData(self, {cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(event:getCostData(self).cards, mumu.name, player, player)
    if player.dead or #room:canMoveCardInBoard("e") == 0 then return end
    local targets = room:askToChooseToMoveCardInBoard(player, {
      skill_name = mumu.name,
      flag = "e",
      prompt = "#sxfy__mumu-move",
      cancelable = false,
    })
    room:askToMoveCardInBoard(player, {
      skill_name = mumu.name,
      flag = "e",
      target_one = targets[1],
      target_two = targets[2],
    })
  end,
})

return mumu
