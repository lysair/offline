local xijun = fk.CreateSkill {
  name = "xijun",
}

Fk:loadTranslationTable{
  ["xijun"] = "袭军",
  [":xijun"] = "每回合限两次，出牌阶段或当你受到伤害后，你可以将一张黑色牌当【杀】或【决斗】使用或打出，当一名角色受到此牌造成的伤害后，"..
  "防止其本回合回复体力。",

  ["#xijun"] = "袭军：你可以将一张黑色牌当【杀】或【决斗】使用或打出，受到此牌伤害的角色本回合不能回复体力！",
  ["@@xijun-turn"] = "禁止回复体力",
}

xijun:addEffect("viewas", {
  anim_type = "offensive",
  pattern = "slash,duel",
  prompt = "#xijun",
  interaction = function(self, player)
    local all_names = {"slash", "duel"}
    local names = player:getViewAsCardNames(xijun.name, all_names)
    if #names > 0 then
      return UI.CardNameBox { choices = names, all_choices = all_names }
    end
  end,
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).color == Card.Black
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 or not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = xijun.name
    card:addSubcard(cards[1])
    return card
  end,
  enabled_at_play = function (self, player)
    return player:usedSkillTimes(xijun.name, Player.HistoryTurn) < 2
  end,
  enabled_at_response = function (self, player)
    return player:usedSkillTimes(xijun.name, Player.HistoryTurn) < 2 and player.phase == Player.Play
  end,
})

xijun:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xijun.name) and
      player:usedSkillTimes(xijun.name, Player.HistoryTurn) < 2
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local success, dat = room:askToUseActiveSkill(player, {
      skill_name = xijun.name,
      prompt = "#xijun",
      cancelable = true,
      extra_data = {
        bypass_times = true,
        extraUse = true,
      },
      skip = true,
    })
    if success and dat then
      event:setCostData(self, {extra_data = dat})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local dat = event:getCostData(self).extra_data
    local card = Fk:cloneCard(dat.interaction)
    card.skillName = xijun.name
    card:addSubcards(dat.cards)
    room:useCard({
      from = player,
      tos = dat.targets,
      card = card,
      extraUse = true,
    })
  end,

  can_refresh = function (self, event, target, player, data)
    return target == player and data.card and table.contains(data.card.skillNames, xijun.name) and not player.dead
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "@@xijun-turn", 1)
  end,
})

xijun:addEffect(fk.PreHpRecover, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@@xijun-turn") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    data:preventRecover()
  end,
})

return xijun
