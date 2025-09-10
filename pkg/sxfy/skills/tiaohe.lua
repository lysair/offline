local tiaohe = fk.CreateSkill {
  name = "sxfy__tiaohe",
}

Fk:loadTranslationTable{
  ["sxfy__tiaohe"] = "调和",
  [":sxfy__tiaohe"] = "出牌阶段限一次，你可以弃置场上一张武器牌和一张防具牌（不能为同一名角色的牌）。",

  ["#sxfy__tiaohe"] = "调和：选择两名角色，弃置一名角色的武器牌和另一名角色的防具牌",
  ["#sxfy__tiaohe-discard"] = "调和：选择弃置 %dest 的装备",
}

tiaohe:addEffect("active", {
  anim_type = "control",
  prompt = "#sxfy__tiaohe",
  card_num = 0,
  target_num = 2,
  can_use = function(self, player)
    return player:usedSkillTimes(tiaohe.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected == 0 then
      return #to_select:getEquipments(Card.SubtypeWeapon) > 0 or #to_select:getEquipments(Card.SubtypeArmor) > 0
    elseif #selected == 1 then
      if #selected[1]:getEquipments(Card.SubtypeWeapon) > 0 and #selected[1]:getEquipments(Card.SubtypeArmor) == 0 then
        return #to_select:getEquipments(Card.SubtypeArmor) > 0
      elseif #selected[1]:getEquipments(Card.SubtypeWeapon) == 0 and #selected[1]:getEquipments(Card.SubtypeArmor) > 0 then
        return #to_select:getEquipments(Card.SubtypeWeapon) > 0
      elseif #selected[1]:getEquipments(Card.SubtypeWeapon) > 0 and #selected[1]:getEquipments(Card.SubtypeArmor) > 0 then
        return #to_select:getEquipments(Card.SubtypeWeapon) > 0 or #to_select:getEquipments(Card.SubtypeArmor) > 0
      end
    end
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    room:sortByAction(effect.tos)
    local tag = {"", ""}
    for i = 1, 2, 1 do
      if #effect.tos[i]:getEquipments(Card.SubtypeWeapon) > 0 then
        tag[i] = tag[i].."w"
      end
      if #effect.tos[i]:getEquipments(Card.SubtypeArmor) > 0 then
        tag[i] = tag[i].."a"
      end
    end
    if string.len(tag[2]) == 1 then
      if tag[2] == "w" then
        tag[1] = "a"
      else
        tag[1] = "w"
      end
    end
    local moves = {}
    for i = 1, 2, 1 do
      local sub_type, card = 1, 0
      if string.len(tag[i]) == 1 then
        if tag[i] == "w" then
          sub_type = Card.SubtypeWeapon
        else
          sub_type = Card.SubtypeArmor
        end
        card = effect.tos[i]:getEquipments(sub_type)[1]
        if #effect.tos[i]:getEquipments(sub_type) > 1 then
          local cards = table.filter(effect.tos[i]:getCardIds("e"), function (id)
            return Fk:getCardById(id).sub_type == sub_type
          end)
          card = room:askToChooseCard(player, {
            target = effect.tos[i],
            flag = { card_data = {{ effect.tos[i].general, cards }} },
            skill_name = tiaohe.name,
            prompt = "#sxfy__tiaohe-discard::"..effect.tos[i].id,
          })
        end
      else
        local cards = table.filter(effect.tos[i]:getCardIds("e"), function (id)
          return Fk:getCardById(id).sub_type == Card.SubtypeWeapon or Fk:getCardById(id).sub_type == Card.SubtypeArmor
        end)
        card = room:askToChooseCard(player, {
          target = effect.tos[i],
          flag = { card_data = {{ effect.tos[i].general, cards }} },
          skill_name = tiaohe.name,
          prompt = "#sxfy__tiaohe-discard::"..effect.tos[i].id,
        })
      end
      if i == 1 and string.len(tag[2]) == 2 then
        if Fk:getCardById(card).sub_type == Card.SubtypeWeapon then
          tag[2] = "a"
        else
          tag[2] = "w"
        end
      end
      table.insert(moves, {
        ids = { card },
        from = effect.tos[i],
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonDiscard,
        proposer = player,
        skillName = tiaohe.name,
      })
    end
    room:moveCards(table.unpack(moves))
  end,
})

return tiaohe
