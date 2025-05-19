local chuce = fk.CreateSkill {
  name = "chuce",
}

Fk:loadTranslationTable{
  ["chuce"] = "出策",
  [":chuce"] = "你可以将锦囊牌当任意基本牌或锦囊牌使用（无距离次数限制）。每回合限一次，当其他角色使用锦囊牌时，你可以摸三张牌令此牌无效，"..
  "然后你可以视为使用之。",

  ["#chuce"] = "出策：你可以将锦囊牌当任意基本牌或锦囊牌使用",
  ["#chuce-invoke"] = "出策：是否摸三张牌，令 %dest 使用的%arg无效且你可以视为使用之？",
  ["#chuce-use"] = "出策：你可以视为使用【%arg】",
}

local U = require "packages/utility/utility"

chuce:addEffect("viewas", {
  pattern = ".",
  prompt = "#chuce",
  interaction = function(self, player)
    local all_names = Fk:getAllCardNames("btd")
    local names = player:getViewAsCardNames(chuce.name, all_names)
    if #names == 0 then return end
    return U.CardNameBox { choices = names, all_choices = all_names}
  end,
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).type == Card.TypeTrick
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 or Fk.all_card_types[self.interaction.data] == nil then return end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcard(cards[1])
    card.skillName = chuce.name
    return card
  end,
  enabled_at_response = function (self, player, response)
    return not response
  end,
})

chuce:addEffect(fk.CardUsing, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    return target ~= player and player:hasSkill(chuce.name) and
      data.card.type == Card.TypeTrick and player:usedEffectTimes(self.name, Player.HistoryTurn) == 0
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = chuce.name,
      prompt = "#chuce-invoke::"..target.id..":"..data.card:toLogString(),
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:addTableMarkIfNeed(player, "longmu", target.id)
    data.toCard = nil
    data.nullifiedTargets = table.simpleClone(room.players)
    player:drawCards(3, chuce.name)
    if not player.dead and data.card.sub_type ~= Card.SubtypeDelayedTrick then
      room:askToUseVirtualCard(player, {
        name = data.card.name,
        skill_name = chuce.name,
        prompt = "#chuce-use:::"..data.card.name,
        cancelable = true,
        extra_data = {
          bypass_times = true,
          extraUse = true,
        },
      })
    end
  end,
})

chuce:addEffect("targetmod", {
  bypass_distances = function (self, player, skill, card, to)
    return card and table.contains(card.skillNames, chuce.name) and #Card:getIdList(card) == 1
  end,
  bypass_times = function (self, player, skill, scope, card, to)
    return card and table.contains(card.skillNames, chuce.name) and #Card:getIdList(card) == 1
  end,
})

return chuce
