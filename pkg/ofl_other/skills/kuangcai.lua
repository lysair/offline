local kuangcai = fk.CreateSkill {
  name = "ofl__kuangcai"
}

Fk:loadTranslationTable{
  ['ofl__kuangcai'] = '狂才',
  ['#ofl__kuangcai-invoke'] = '祢衡：可令本阶段使用牌时无次数距离限制且摸一张牌，所有角色至多使用5张牌！',
  ['@ofl__kuangcai-phase'] = '狂才',
  [':ofl__kuangcai'] = '出牌阶段开始时，你可以令你此阶段使用牌无次数距离限制且当你使用牌时你摸一张牌。若如此做，本阶段所有角色合计使用牌数不能超过五张。',
  ['$ofl__kuangcai1'] = '（激烈的鼓声）',
  ['$ofl__kuangcai2'] = '来吧，速战速决！',
}

-- Trigger Skill Effect
kuangcai:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player)
    if target == player and player:hasSkill(kuangcai.name) then
      return player.phase == Player.Play
    end
  end,
  on_cost = function(self, event, target, player)
    return player.room:askToSkillInvoke(player, { skill_name = kuangcai.name, prompt = "#ofl__kuangcai-invoke" })
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    room:notifySkillInvoked(player, kuangcai.name, "drawcard")
    player:broadcastSkillInvoke(kuangcai.name, 2)
    room:setPlayerMark(player, "ofl__kuangcai-phase", 1)
    room:setPlayerMark(player, "@ofl__kuangcai-phase", 5)
  end,
})

-- Trigger Skill Effect
kuangcai:addEffect(fk.CardUsing, {
  can_trigger = function(self, event, target, player)
    if target == player and player:hasSkill(kuangcai.name) then
      return player:getMark("ofl__kuangcai-phase") > 0
    end
  end,
  on_cost = function(self, event, target, player)
    return true
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    room:notifySkillInvoked(player, kuangcai.name, "drawcard")
    player:broadcastSkillInvoke(kuangcai.name, 1)
    player:drawCards(1, kuangcai.name)
  end,

  can_refresh = function (self, event, target, player)
    return player:getMark("@ofl__kuangcai-phase") > 0
  end,
  on_refresh = function (self, event, target, player)
    player.room:removePlayerMark(player, "@ofl__kuangcai-phase")
  end,
})

-- TargetModSkill Effect
kuangcai:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card)
    return card and player:getMark("ofl__kuangcai-phase") > 0
  end,
  bypass_distances = function(self, player, skill, card)
    return card and player:getMark("ofl__kuangcai-phase") > 0
  end,
})

-- ProhibitSkill Effect
kuangcai:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    return table.find(Fk:currentRoom().alive_players, function (p)
      return p:getMark("ofl__kuangcai-phase") > 0 and p:getMark("@ofl__kuangcai-phase") == 0
    end)
  end,
})

return kuangcai
