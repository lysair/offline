local xiandao = fk.CreateSkill{
  name = "xiandao",
}

Fk:loadTranslationTable{
  ["xiandao"] = "献刀",
  [":xiandao"] = "每回合限一次，你赠予其他角色牌后，你可以令其本回合不能使用此花色的牌，然后若此牌为：锦囊牌，你摸两张牌；装备牌，你获得其另一张牌；"..
  "武器牌，你对其造成1点伤害。",

  ["#xiandao-invoke"] = "献刀：你赠予了 %dest %arg，是否对其发动“献刀”？",
  ["@xiandao-turn"] = "献刀",
  ["#xiandao-prey"] = "献刀：获得其另一张牌",
}

local U = require "packages/utility/utility"

Fk:addPoxiMethod{
  name = "xiandao",
  prompt = "#xiandao-prey",
  card_filter = function(to_select, selected, data, extra_data)
    return #selected == 0 and to_select ~= extra_data.xiandao
  end,
  feasible = function(selected)
    return #selected == 1
  end,
  default_choice = function (data, extra_data)
    for _, v in pairs(data) do
      for _, id in ipairs(v) do
        if id ~= extra_data.xiandao then
          return {id}
        end
      end
    end
  end,
}

xiandao:addEffect(U.AfterPresentCard, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xiandao.name) and
      player:usedSkillTimes(xiandao.name, Player.HistoryTurn) == 0 and
      not data.to.dead
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = xiandao.name,
      prompt = "#xiandao-invoke::"..data.to.id..":"..data.card:toLogString(),
    }) then
      event:setCostData(self, {tos = {data.to}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = data.card
    room:addTableMarkIfNeed(data.to, "@xiandao-turn", card:getSuitString(true))
    if not player.dead then
      if card.type == Card.TypeTrick then
        player:drawCards(2, xiandao.name)
      elseif card.type == Card.TypeEquip then
        if not data.to.dead and not data.to:isNude() then
          local all_cards = data.to:getCardIds("he")
          table.removeOne(all_cards, card.id)
          if #all_cards > 0 then
            local card_data = {}
            local extra_data = {}
            local visible_data = {}
            if not data.to:isKongcheng() then
              table.insert(card_data, { "$Hand", data.to:getCardIds("h") })
              for _, id in ipairs(data.to:getCardIds("h")) do
                if not player:cardVisible(id) then
                  visible_data[tostring(id)] = false
                end
              end
              if next(visible_data) == nil then visible_data = nil end
            end
            if #data.to:getCardIds("e") > 0 then
              table.insert(card_data, { "$Equip", data.to:getCardIds("e") })
            end
            extra_data.visible_data = visible_data
            extra_data.xiandao = card.id
            card = room:askToPoxi(player, {
              poxi_type = xiandao.name,
              data = card_data,
              extra_data = extra_data,
              cancelable = false,
            })
            room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, xiandao.name, nil, false, player)
          end
          if card.sub_type == Card.SubtypeWeapon and not data.to.dead then
            room:damage{
              from = player,
              to = data.to,
              damage = 1,
              skillName = xiandao.name,
            }
          end
        end
      end
    end
  end,
})

xiandao:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    return card and player:getMark("@xiandao-turn") ~= 0 and table.contains(player:getMark("@xiandao-turn"), card:getSuitString(true))
  end,
})

return xiandao
