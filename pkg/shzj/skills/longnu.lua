local longnu = fk.CreateSkill {
  name = "shzj_yiling__longnu",
  tags = { Skill.Switch },
}

Fk:loadTranslationTable{
  ["shzj_yiling__longnu"] = "龙怒",
  [":shzj_yiling__longnu"] = "转换技，游戏开始时可自选阴阳状态；出牌阶段开始时，你可以摸一张牌，阳：失去1点体力，你此阶段可以将红色牌当"..
  "无距离限制的火【杀】使用或打出；阴：减1点体力上限，你此阶段可以将锦囊牌当无次数限制的雷【杀】使用或打出。",

  ["#shzj_yiling__longnu_yang"] = "龙怒：你可以将红色牌当无距离限制的火【杀】使用或打出",
  ["#shzj_yiling__longnu_yin"] = "龙怒：你可以将锦囊牌当无次数限制的雷【杀】使用或打出",
  ["#shzj_yiling__longnu_yang-invoke"] = "龙怒：是否摸一张牌并失去1点体力，此阶段可以将红色牌当无距离限制的火【杀】使用或打出？",
  ["#shzj_yiling__longnu_yin-invoke"] = "龙怒：是否摸一张牌并减1点体力上限，此阶段可以将锦囊牌当无次数限制的雷【杀】使用或打出？",
}

local U = require "packages/utility/utility"

longnu:addEffect("viewas", {
  anim_type = "offensive",
  pattern = "slash|.|.|.|fire__slash,thunder__slash",
  prompt = function (self, player)
    if player:getMark("shzj_yiling__longnu-phase") == "yang" then
      return "#shzj_yiling__longnu_yang"
    elseif player:getMark("shzj_yiling__longnu-phase") == "yin" then
      return "#shzj_yiling__longnu_yin"
    end
  end,
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    if #selected == 0 then
      if player:getMark("shzj_yiling__longnu-phase") == "yang" then
        return Fk:getCardById(to_select).color == Card.Red
      elseif player:getMark("shzj_yiling__longnu-phase") == "yin" then
        return Fk:getCardById(to_select).type == Card.TypeTrick
      end
    end
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("slash")
    if player:getMark("shzj_yiling__longnu-phase") == "yang" then
      card = Fk:cloneCard("fire__slash")
    elseif player:getMark("shzj_yiling__longnu-phase") == "yin" then
      card = Fk:cloneCard("thunder__slash")
    end
    card:addSubcard(cards[1])
    card.skillName = longnu.name
    return card
  end,
  before_use = function (self, player, use)
    U.SetSwitchSkillState(player, longnu.name, player:getSwitchSkillState(longnu.name, true))
  end,
  enabled_at_play = function (self, player)
    return player:getMark("shzj_yiling__longnu-phase") ~= 0
  end,
  enabled_at_response = function (self, player)
    return player:getMark("shzj_yiling__longnu-phase") ~= 0
  end,
})

longnu:addEffect(fk.EventPhaseStart, {
  anim_type = "switch",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(longnu.name) and player.phase == Player.Play
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = longnu.name,
      prompt = "#shzj_yiling__longnu_"..player:getSwitchSkillState(longnu.name, false, true).."-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "shzj_yiling__longnu-phase", player:getSwitchSkillState(longnu.name, true, true))
    player:drawCards(1, longnu.name)
    if player.dead then return end
    if player:getSwitchSkillState(longnu.name, true) == fk.SwitchYang then
      room:loseHp(player, 1, longnu.name)
    else
      room:changeMaxHp(player, -1)
    end
  end,
})

longnu:addEffect("targetmod", {
  bypass_distances =  function(self, player, skill, card, to)
    return player:getMark("shzj_yiling__longnu-phase") == "yang" and
      table.contains(card.skillNames, longnu.name)
  end,
  bypass_times = function(self, player, skill, scope, card, to)
    return card and player:getMark("shzj_yiling__longnu-phase") == "yin" and scope == Player.HistoryPhase and
      table.contains(card.skillNames, longnu.name)
  end,
})

longnu:addEffect(fk.GameStart, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(longnu.name, true)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = room:askToChoice(player, {
      choices = { "tymou_switch:::shzj_yiling__longnu:yang", "tymou_switch:::shzj_yiling__longnu:yin" },
      skill_name = longnu.name,
      prompt = "#tymou_switch-choice:::shzj_yiling__longnu",
    })
    choice = choice:endsWith("yang") and fk.SwitchYang or fk.SwitchYin
    U.SetSwitchSkillState(player, longnu.name, choice)
  end,
})

return longnu
