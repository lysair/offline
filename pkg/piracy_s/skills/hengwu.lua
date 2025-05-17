local hengwu = fk.CreateSkill {
  name = "ofl2__hengwu",
}

Fk:loadTranslationTable{
  ["ofl2__hengwu"] = "横骛",
  [":ofl2__hengwu"] = "当你使用或打出牌时，若场上有与之花色相同的装备牌，你可以弃置任意张与之花色相同的手牌，然后摸X张牌（X为你以此法弃置的牌数"..
  "与场上该花色的装备牌数之和）。",

  ["#ofl2__hengwu-invoke"] = "横骛：你可以弃置任意张%arg手牌，摸弃牌数+场上此花色装备数张牌",

  ["$ofl2__hengwu1"] = "雷部显圣，引赤电为翼，铸霹雳成枪！",
  ["$ofl2__hengwu2"] = "一骑破霄汉，饮马星河、醉卧广寒！",
}

local spec = {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(hengwu.name) and
      table.find(player.room.alive_players, function (p)
        return table.find(p:getCardIds("e"), function (id)
          return Fk:getCardById(id):compareSuitWith(data.card)
        end) ~= nil
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local success, dat = room:askToUseActiveSkill(player, {
      skill_name = "discard_skill",
      prompt = "#ofl2__hengwu-invoke:::"..data.card:getSuitString(true),
      cancelable = true,
      extra_data = {
        num = 999,
        min_num = 0,
        include_equip = false,
        pattern = ".|.|"..data.card:getSuitString(),
        skillName = hengwu.name,
      }
    })
    if success and dat then
      event:setCostData(self, {cards = dat.cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = event:getCostData(self).cards
    local x = #cards
    for _, p in ipairs(room.alive_players) do
      for _, id in ipairs(p:getCardIds("e")) do
        if Fk:getCardById(id):compareSuitWith(data.card) then
          x = x + 1
        end
      end
    end
    if #cards > 0 then
      room:throwCard(cards, hengwu.name, player, player)
    end
    player:drawCards(x, hengwu.name)
  end,
}

hengwu:addEffect(fk.CardUsing, spec)
hengwu:addEffect(fk.CardResponding, spec)

return hengwu
