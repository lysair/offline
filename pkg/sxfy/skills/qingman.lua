local qingman = fk.CreateSkill {
  name = "sxfy__qingman",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["sxfy__qingman"] = "轻幔",
  [":sxfy__qingman"] = "锁定技，回合结束时，你将手牌数调整为X（X为当你空置的装备栏数，至多为3）。",
}

qingman:addEffect(fk.TurnEnd, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(qingman.name) and
      player:getHandcardNum() ~= math.min(#player:getAvailableEquipSlots() - #player:getCardIds("e"), 3)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = player:getHandcardNum() - math.min(#player:getAvailableEquipSlots() - #player:getCardIds("e"), 3)
    if n > 0 then
      room:askToDiscard(player, {
        min_num = n,
        max_num = n,
        include_equip = false,
        skill_name = qingman.name,
        cancelable = false,
      })
    else
      player:drawCards(-n, qingman.name)
    end
  end,
})

return qingman
