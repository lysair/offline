local wusheng = fk.CreateSkill{
  name = "ofl_mou__wusheng",
}

Fk:loadTranslationTable{
  ["ofl_mou__wusheng"] = "武圣",
  [":ofl_mou__wusheng"] = "你可以将一张手牌当任意【杀】使用或打出；出牌阶段开始时，你可以令一名其他角色展示所有手牌，" ..
  "本阶段你对其使用前X张【杀】无距离次数限制且结算结束后摸一张牌（X为其展示的红色牌数）。",

  ["#ofl_mou__wusheng"] = "武圣：将一张手牌当任意【杀】使用或打出",
  ["#ofl_mou__wusheng-choose"] = "武圣：令一名角色展示手牌，根据其中红色牌数，此阶段你对其使用【杀】获得增益",
  ["@ofl_mou__wusheng-phase"] = "武圣",

  ["$ofl_mou__wusheng1"] = "敌酋虽勇，亦非关某一合之将！",
  ["$ofl_mou__wusheng2"] = "酒且斟下，关某片刻便归。",
  ["$ofl_mou__wusheng3"] = "煮酒待温方适饮！",
}

local U = require "packages/utility/utility"

wusheng:addEffect("viewas", {
  anim_type = "offensive",
  pattern = "slash",
  prompt = "#ofl_mou__wusheng",
  interaction = function(self, player)
    local all_names = table.filter(Fk:getAllCardNames("b"), function(name)
      return Fk:cloneCard(name).trueName == "slash"
    end)
    local names = player:getViewAsCardNames(wusheng.name, all_names)
    return U.CardNameBox { choices = names, all_choices = all_names }
  end,
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected == 1 and table.contains(player:getHandlyIds(), to_select)
  end,
  view_as = function(self, player, cards)
    if self.interaction.data == nil or #cards ~= 1 then return end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcards(cards)
    card.skillName = wusheng.name
    return card
  end,
})

wusheng:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(wusheng.name) and player.phase == Player.Play and
      table.find(player.room:getOtherPlayers(player, false), function(p)
        return not p:isKongcheng()
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function(p)
      return not p:isKongcheng()
    end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = wusheng.name,
      prompt = "#ofl_mou__wusheng-choose",
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local cards = table.simpleClone(to:getCardIds("h"))
    to:showCards(cards)
    if player.dead or to.dead then return end
    local reds = table.filter(cards, function(id)
      return Fk:getCardById(id).color == Card.Red
    end)
    if #reds > 0 then
      room:setPlayerMark(to, "@ofl_mou__wusheng-phase", #reds)
    end
  end,
})

wusheng:addEffect("targetmod", {
  bypass_distances = function (self, player, skill, card, to)
    return card and player:usedSkillTimes(wusheng.name, Player.HistoryPhase) > 0 and
      card.trueName == "slash" and to:getMark("@ofl_mou__wusheng-phase") > 0
  end,
  bypass_times = function (self, player, skill, scope, card, to)
    return card and player:usedSkillTimes(wusheng.name, Player.HistoryPhase) > 0 and
      card.trueName == "slash" and to:getMark("@ofl_mou__wusheng-phase") > 0
  end,
})

wusheng:addEffect(fk.PreCardUse, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:usedSkillTimes(wusheng.name, Player.HistoryPhase) > 0 and
      data.card.trueName == "slash"
  end,
  on_refresh = function (self, event, target, player, data)
    for _, p in ipairs(data.tos) do
      if p:getMark("@ofl_mou__wusheng-phase") > 0 then
        player.room:removePlayerMark(p, "@ofl_mou__wusheng-phase", 1)
        data.extraUse = true
        data.extra_data = data.extra_data or {}
        data.extra_data.ofl_mou__wusheng = player
      end
    end
  end,
})

wusheng:addEffect(fk.CardUseFinished, {
  anim_type = "drawcard",
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and not player.dead and
      data.extra_data and data.extra_data.ofl_mou__wusheng == player
  end,
  on_use = function (self, event, target, player, data)
    player:drawCards(1, wusheng.name)
  end,
})

return wusheng
