local shanjia = fk.CreateSkill {
  name = "sxfy__shanjia",
}

Fk:loadTranslationTable{
  ["sxfy__shanjia"] = "缮甲",
  [":sxfy__shanjia"] = "出牌阶段开始时，你可以摸X张牌，然后弃置X张牌（X为你装备区的牌数+1），若你本次弃置的牌均为装备牌，"..
  "你视为使用一张无次数限制的【杀】。",

  ["#sxfy__shanjia-discard"] = "缮甲：弃置%arg张牌，若均为装备牌则视为使用【杀】",
  ["#sxfy__shanjia-slash"] = "缮甲：视为使用一张无次数限制的【杀】",
}

shanjia:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shanjia.name) and player.phase == Player.Play
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(#player:getCardIds("e") + 1, shanjia.name)
    if player.dead then return end
    local n = #player:getCardIds("e") + 1
    local cards = room:askToDiscard(player, {
      min_num = n,
      max_num = n,
      include_equip = true,
      skill_name = shanjia.name,
      cancelable = false,
      prompt = "#sxfy__shanjia-discard:::"..n,
      skip = true,
    })
    if #cards > 0 then
      local shanjia_failure = table.find(cards, function (id)
        return Fk:getCardById(id).type ~= Card.TypeEquip
      end)
      room:throwCard(cards, shanjia.name, player, player)
      if player.dead or shanjia_failure then return end
    end
    room:askToUseVirtualCard(player, {
      name = "slash",
      skill_name = shanjia.name,
      prompt = "#sxfy__shanjia-slash",
      extra_data = {
        bypass_times = true,
        extraUse = true,
      },
      cancelable = false,
    })
  end,
})

return shanjia
