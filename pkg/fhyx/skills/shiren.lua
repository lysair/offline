local shiren = fk.CreateSkill {
  name = "ofl_shiji__shiren",
}

Fk:loadTranslationTable{
  ["ofl_shiji__shiren"] = "施仁",
  [":ofl_shiji__shiren"] = "当你成为其他角色使用伤害类牌的目标后，你可以选择一项：1.将牌堆顶两张牌置入<a href='RenPile_href'>“仁”区</a>，"..
  "然后你获得一张“仁”区牌；2.摸两张牌，然后将一张手牌置入“仁”区。",

  ["ofl_shiji__shiren1"] = "将牌堆顶两张牌置入仁区，获得一张仁区牌",
  ["ofl_shiji__shiren2"] = "摸两张牌，将一张手牌置入仁区",
  ["#ofl_shiji__shiren-prey"] = "施仁：获得一张“仁”区牌",
  ["#ofl_shiji__shiren-card"] = "施仁：请将一张手牌置入仁区",
}

local U = require "packages/utility/utility"

shiren:addEffect(fk.TargetConfirmed, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shiren.name) and
      data.from ~= player and data.card.is_damage_card
  end,
  on_cost = function (self, event, target, player, data)
    local choice = player.room:askToChoice(player, {
      choices = {"ofl_shiji__shiren1", "ofl_shiji__shiren2", "Cancel"},
      skill_name = shiren.name,
    })
    if choice ~= "Cancel" then
      event:setCostData(self, {choice = choice})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event:getCostData(self).choice == "ofl_shiji__shiren1" then
      U.AddToRenPile(player, room:getNCards(2), shiren.name)
      local cards = U.GetRenPile(room)
      if #cards == 0 then return end
      local card = room:askToChooseCard(player, {
        target = player,
        flag = { card_data = {{ "$RenPile", cards }} },
        skill_name = shiren.name,
        prompt = "#ofl_shiji__shiren-prey",
      })
      room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonJustMove, shiren.name, nil, true, player)
    else
      player:drawCards(2, shiren.name)
      if player.dead or player:isKongcheng() then return end
      local card = room:askToCards(player, {
        min_num = 1,
        max_num = 1,
        skill_name = shiren.name,
        prompt = "#ofl_shiji__shiren-card",
        cancelable = false,
      })
      U.AddToRenPile(player, card, shiren.name)
    end
  end,
})

return shiren
