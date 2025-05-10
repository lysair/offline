local mingdao = fk.CreateSkill {
  name = "ofl__mingdao",
}

Fk:loadTranslationTable{
  ["ofl__mingdao"] = "瞑道",
  [":ofl__mingdao"] = "游戏开始时，你可以将一张<a href='populace_href'>【众】</a>置入你的装备区，【众】离开你的装备区时销毁。",

  ["populace_href"] = "【众】共有四张，分别为♠A/<font color='red'>♥A</font>/♣A/<font color='red'>♦A</font>，类别为装备牌·武器/防具/坐骑，"..
  "每种花色的【众】可以置入任意武器/防具/坐骑，效果各不相同。",

  ["#ofl__mingdao-invoke"] = "瞑道：将一张“众”置入你的装备区（选择一种“众”及副类别，右键/长按可查看技能）",
}

local U = require "packages/utility/utility"

local mapper = {"weapon", "armor", "defensive_horse", "offensive_horse"}

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
        room:printCard("spade__populace", Card.Spade, 1).id,
        room:printCard("heart__populace", Card.Heart, 1).id,
        room:printCard("club__populace", Card.Club, 1).id,
        room:printCard("diamond__populace", Card.Diamond, 1).id,
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
    local index = table.indexOf(mapper, string.sub(event:getCostData(self).interaction, 6))
    local suits = {"spade", "heart", "club", "diamond"}
    local card_name = suits[index].."__populace"
    local suit = string.split(Fk:getCardById(event:getCostData(self).cards[1]).name, "_")[1]
    suit = U.ConvertSuit(suit, "str", "int")
    local populaces = room:getBanner("mingdao_populace") or {}
    local card = table.find(populaces, function (id)
      local c = Fk:getCardById(id)
      return room:getCardArea(id) == Card.Void and c.name == card_name and c.suit == suit
    end)
    if card == nil then
      local id = room:printCard(card_name, suit, 1).id
      table.insert(populaces, id)
      room:setBanner("mingdao_populace", populaces)
      card = id
    end
    room:setCardMark(Fk:getCardById(card), MarkEnum.DestructOutMyEquip, 1)
    room:moveCardIntoEquip(player, card, mingdao.name, false, player)
  end,
})

return mingdao
