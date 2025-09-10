local zhuide = fk.CreateSkill {
  name = "sxfy__zhuide",
}

Fk:loadTranslationTable{
  ["sxfy__zhuide"] = "追德",
  [":sxfy__zhuide"] = "当你死亡时，你展示牌堆顶四张牌，并令一名其他角色获得其中的基本牌。",

  ["#sxfy__zhuide-choose"] = "追德：令一名角色获得其中的基本牌",
}

zhuide:addEffect(fk.Death, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zhuide.name, false, true)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = room:getNCards(4)
    room:showCards(cards)
    cards = table.filter(cards, function (id)
      return Fk:getCardById(id).type == Card.TypeBasic
    end)
    if #cards > 0 and #room:getOtherPlayers(player, false) > 0 then
      local to = room:askToChoosePlayers(player, {
        targets = room:getOtherPlayers(player, false),
        min_num = 1,
        max_num = 1,
        prompt = "#sxfy__zhuide-choose",
        skill_name = zhuide.name,
        cancelable = false,
      })[1]
      room:obtainCard(to, cards, true, fk.ReasonDraw, to, zhuide.name)
    end
  end,
})

return zhuide
