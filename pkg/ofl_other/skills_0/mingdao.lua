local mingdao = fk.CreateSkill {
  name = "ofl__mingdao"
}

Fk:loadTranslationTable{
  ['ofl__mingdao'] = '瞑道',
  ['ofl__mingdao_active'] = '瞑道',
  ['#ofl__mingdao-invoke'] = '瞑道：将一张“众”置入你的装备区（选择一种“众”及副类别，右键/长按可查看技能）',
  [':ofl__mingdao'] = '游戏开始时，你可以将一张<a href=>【众】</a>置入你的装备区，【众】进入离开你的装备区时销毁。',
}

mingdao:addEffect(fk.GameStart, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(mingdao.name) and
      table.find({3, 4, 5, 6}, function (sub_type)
        return player:hasEmptyEquipSlot(sub_type)
      end)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if not room:getBanner(mingdao.name) then
      room:setBanner(mingdao.name, {
        room:printCard("weapon1__populace", Card.Heart, 1).id,
        room:printCard("armor1__populace", Card.Diamond, 1).id,
        room:printCard("defensive_horse1__populace", Card.Club, 1).id,
        room:printCard("offensive_horse1__populace", Card.Spade, 1).id,
      })
    end
    local success, dat = room:askToUseActiveSkill(player, {
      skill_name = "ofl__mingdao_active",
      prompt = "#ofl__mingdao-invoke",
      cancelable = true
    })
    if success and dat then
      event:setCostData(self, dat)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local index = table.indexOf(mingdao_mapper, string.sub(event:getCostData(self).interaction, 6))
    local skill = string.split(Fk:getCardById(event:getCostData(self).cards[1]).name, "1")[1]
    local name = skill..tostring(index).."__populace"
    local suit
    if skill == "weapon" then
      suit = Card.Heart
    elseif skill == "armor" then
      suit = Card.Diamond
    elseif skill == "defensive_horse" then
      suit = Card.Club
    elseif skill == "offensive_horse" then
      suit = Card.Spade
    end
    local tag = room.tag[mingdao.name] or {}
    local card = table.find(tag, function (id)
      local c = Fk:getCardById(id)
      return room:getCardArea(id) == Card.Void and c.name == name and c.suit == suit
    end)
    if card == nil then
      local id = room:printCard(name, suit, 1).id
      table.insert(tag, id)
      room:setTag(mingdao.name, tag)
      card = id
    end
    room:setCardMark(Fk:getCardById(card), MarkEnum.DestructOutMyEquip, 1)
    room:moveCardIntoEquip(player, card, mingdao.name, false, player.id)
  end,
})

return mingdao
