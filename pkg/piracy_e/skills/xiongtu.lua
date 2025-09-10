local xiongtu = fk.CreateSkill {
  name = "xiongtu",
}

Fk:loadTranslationTable{
  ["xiongtu"] = "雄图",
  [":xiongtu"] = "当你的体力值变化后，你可以从牌堆、弃牌堆、场上、处理区各获得一张伤害牌。",

  ["$xiongtu1"] = "宁负奸雄骂名，胜过英雄短命！",
  ["$xiongtu2"] = "为谋霸业，小损无妨！",
}

xiongtu:addEffect(fk.HpChanged, {
  anim_type = "masochism",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(xiongtu.name)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    for _, cards in ipairs({room.draw_pile, room.discard_pile, room.processing_area}) do
      if player.dead then return end
      local ids = table.filter(cards, function (id)
        return Fk:getCardById(id).is_damage_card
      end)
      if #ids > 0 then
        local card = room:askToChooseCard(player, {
          target = player,
          flag = { card_data = {{ "toObtain", ids }} },
          skill_name = xiongtu.name,
        })
        room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonJustMove, xiongtu.name, nil, true, player)
      end
    end
  end,
})

return xiongtu
