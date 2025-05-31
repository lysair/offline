local anmou = fk.CreateSkill {
  name = "anmou",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["anmou"] = "暗谋",
  [":anmou"] = "锁定技，游戏开始时，你秘密选择一名其他角色，你与其对对方使用牌无次数限制。",

  ["#anmou-choose"] = "暗谋：秘密选择一名角色，你与其对对方使用牌无次数限制！",
}

anmou:addEffect(fk.GameStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(anmou.name) and #player.room:getOtherPlayers(player, false) > 0
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, anmou.name)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player, false),
      skill_name = anmou.name,
      prompt = "#anmou-choose",
      cancelable = false,
      no_indicate = true,
    })[1]
    room:setPlayerMark(player, anmou.name, to.id)
  end,
})

anmou:addEffect(fk.PreCardUse, {
  can_refresh = function (self, event, target, player, data)
    return table.find(data.tos, function (to)
      return player:getMark(anmou.name) == to.id or to:getMark(anmou.name) == player.id
    end)
  end,
  on_refresh = function (self, event, target, player, data)
    data.extraUse = true
  end,
})

anmou:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    return card and to and (player:getMark(anmou.name) == to.id or to:getMark(anmou.name) == player.id)
  end,
})

return anmou
