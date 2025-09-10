
local hengwu = fk.CreateSkill {
  name = "sxfy__hengwu",
}

Fk:loadTranslationTable{
  ["sxfy__hengwu"] = "横骛",
  [":sxfy__hengwu"] = "你可以将一张坐骑牌置入当前回合角色的装备区，视为使用一张【杀】或【闪】，然后其本回合非锁定技失效。",

  ["#sxfy__hengwu"] = "横骛：将一张坐骑牌置入 %dest 装备区，视为使用【杀】或【闪】，其本回合非锁定技失效",
}

hengwu:addEffect("viewas", {
  pattern = "slash,jink",
  prompt = function (self, player, selected_cards, selected)
    return "#sxfy__hengwu::"..Fk:currentRoom().current.id
  end,
  interaction = function(self, player)
    local all_names = {"slash", "jink"}
    local names = player:getViewAsCardNames(hengwu.name, all_names)
    if #names == 0 then return end
    return UI.CardNameBox {choices = names, all_choices = all_names}
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and
      (Fk:getCardById(to_select).sub_type == Card.SubtypeOffensiveRide or
      Fk:getCardById(to_select).sub_type == Card.SubtypeDefensiveRide) and
      Fk:currentRoom().current:canMoveCardIntoEquip(to_select, false)
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 or self.interaction.data == nil then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = hengwu.name
    card:addFakeSubcards(cards)
    return card
  end,
  before_use = function (self, player, use)
    local room = player.room
    local cards = room:moveCardIntoEquip(room.current, use.card.fake_subcards, hengwu.name, false, player)
    if #cards == 0 then return end
  end,
  after_use = function (self, player, use)
    local room = player.room
    if not room.current.dead then
      room:addPlayerMark(room.current, MarkEnum.UncompulsoryInvalidity.."-turn", 1)
    end
  end,
  enabled_at_play = function (self, player)
    return #player:getViewAsCardNames(hengwu.name, {"slash"}) > 0 and
      Fk:currentRoom().current and
      (Fk:currentRoom().current:hasEmptyEquipSlot(Card.SubtypeOffensiveRide) or
      Fk:currentRoom().current:hasEmptyEquipSlot(Card.SubtypeDefensiveRide))
  end,
  enabled_at_response = function (self, player, response)
    return not response and Fk:currentRoom().current and
      (Fk:currentRoom().current:hasEmptyEquipSlot(Card.SubtypeOffensiveRide) or
      Fk:currentRoom().current:hasEmptyEquipSlot(Card.SubtypeDefensiveRide))
  end,
})

return hengwu
