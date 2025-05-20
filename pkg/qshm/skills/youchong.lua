local youchong = fk.CreateSkill {
  name = "youchong",
}

Fk:loadTranslationTable{
  ["youchong"] = "优崇",
  [":youchong"] = "每回合限一次，当你需使用基本牌时，你可以选择任意名手牌数大于你的角色，这些角色可以将三张牌当一张你需要的牌代替你使用。",

  ["#youchong"] = "优崇：声明要使用的牌和目标，然后选择任意名手牌数大于你的角色，这些角色可以将三张牌当一张你需要的牌代替你使用",
  ["#youchong-choose"] = "优崇：选择替你使用牌的角色",
  ["#youchong-ask"] = "优崇：你可以将三张牌当一张【%arg】替 %src 使用",
}

local U = require "packages/utility/utility"

youchong:addEffect("viewas", {
  mute_card = true,
  pattern = ".|.|.|.|.|basic",
  prompt = "#youchong",
  interaction = function(self, player)
    local all_names = Fk:getAllCardNames("b")
    local names = player:getViewAsCardNames(youchong.name, all_names)
    if #names > 0 then
      return U.CardNameBox { choices = names, all_choices = all_names }
    end
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self, player, cards)
    if #cards ~= 0 or self.interaction.data == nil then return end
    local c = Fk:cloneCard(self.interaction.data)
    c.skillName = youchong.name
    return c
  end,
  before_use = function(self, player, use)
    local room = player.room
    room:playCardEmotionAndSound(player, use.card)
    if #use.tos > 0 and not use.noIndicate then
      room:doIndicate(player, use.tos)
    end

    local targets = table.filter(room:getOtherPlayers(player, false), function(p)
      return p:getHandcardNum() > player:getHandcardNum() and #p:getCardIds("he") > 2
    end)
    if #targets == 0 then return " " end
    targets = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = #targets,
      targets = targets,
      skill_name = youchong.name,
      prompt = "#youchong-choose",
      cancelable = false,
    })
    room:sortByAction(targets)
    for _, p in ipairs(targets) do
      local cards = room:askToCards(p, {
        min_num = 3,
        max_num = 3,
        include_equip = true,
        skill_name = youchong.name,
        prompt = "#youchong-ask:"..player.id.."::"..use.card.name,
        cancelable = true,
      })
      if #cards > 0 then
        use.card:addSubcards(cards)
        return
      end
    end
    return youchong.name
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(youchong.name, Player.HistoryTurn) == 0 and
      table.find(Fk:currentRoom().alive_players, function(p)
        return p ~= player and p:getHandcardNum() > player:getHandcardNum() and #p:getCardIds("he") > 2
      end)
  end,
  enabled_at_response = function(self, player, response)
    return not response and
      player:usedSkillTimes(youchong.name, Player.HistoryTurn) == 0 and
      table.find(Fk:currentRoom().alive_players, function(p)
        return p ~= player and p:getHandcardNum() > player:getHandcardNum() and #p:getCardIds("he") > 2
      end)
  end,
})

return youchong
