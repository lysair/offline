local sancai = fk.CreateSkill {
  name = "sancai",
}

Fk:loadTranslationTable{
  ["sancai"] = "散财",
  [":sancai"] = "出牌阶段限一次，你可以展示所有手牌，若均为同一类别，你可以将其中一张牌赠予其他角色。",

  ["#sancai"] = "散财：展示所有手牌，若均为同一类别，你可以将其中一张赠予其他角色",
  ["#sancai-give"] = "散财：你可以将其中一张牌赠予其他角色",
}

local U = require "packages/utility/utility"

sancai:addEffect("active", {
  anim_type = "support",
  prompt = "#sancai",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(sancai.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local cards = player:getCardIds("h")
    player:showCards(cards)
    if player.dead or #room:getOtherPlayers(player, false) == 0 then return end
    if table.every(cards, function(id)
      return Fk:getCardById(id).type == Fk:getCardById(cards[1]).type
    end) then
      cards = table.filter(cards, function(id)
        return table.contains(player:getCardIds("h"), id)
      end)
      if #cards > 0 and #room:getOtherPlayers(player, false) > 0 then
        local to, card = room:askToChooseCardsAndPlayers(player, {
          min_card_num = 1,
          max_card_num = 1,
          min_num = 1,
          max_num = 1,
          pattern = tostring(Exppattern{ id = cards }),
          targets = room:getOtherPlayers(player, false),
          skill_name = sancai.name,
          prompt = "#sancai-give",
          cancelable = true,
          will_throw = true,
        })
        if #to > 0 and card then
          U.presentCard(player, to[1], card[1], sancai.name)
        end
      end
    end
  end,
})

return sancai
