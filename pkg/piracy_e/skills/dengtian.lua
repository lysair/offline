local dengtian = fk.CreateSkill({
  name = "ofl__dengtian",
  tags = { Skill.Compulsory },
  dynamic_desc = function (self, player, lang)
    return "ofl__dengtian_inner:"..
      player:getMark("ofl__dengtian_draw")..":"..
      player:getMark("ofl__dengtian_maxcards")..":"..
      player:getMark("ofl__dengtian_damage")
  end,
})

Fk:loadTranslationTable{
  ["ofl__dengtian"] = "登天",
  [":ofl__dengtian"] = "锁定技，每轮开始时，你选择你以下一项+1：摸牌阶段摸牌数、手牌上限、每回合首次造成伤害的伤害值。",

  [":ofl__dengtian_inner"] = "锁定技，每轮开始时，你选择你以下一项+1：摸牌阶段摸牌数（已+{1}）、手牌上限（已+{2}）、"..
  "每回合首次造成伤害的伤害值（已+{3}）。",

  ["#ofl__dengtian-choice"] = "登天：选择一项+1",
  ["ofl__dengtian_draw"] = "摸牌阶段摸牌数（已+%arg）",
  ["ofl__dengtian_maxcards"] = "手牌上限（已+%arg）",
  ["ofl__dengtian_damage"] = "每回合首次造成伤害（已+%arg）",
}

dengtian:addEffect(fk.RoundStart, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(dengtian.name)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local choice = room:askToChoice(player, {
      choices = {
        "ofl__dengtian_draw:::"..player:getMark("ofl__dengtian_draw"),
        "ofl__dengtian_maxcards:::"..player:getMark("ofl__dengtian_maxcards"),
        "ofl__dengtian_damage:::"..player:getMark("ofl__dengtian_damage"),
      },
      skill_name = dengtian.name,
      prompt = "#ofl__dengtian-choice",
    })
    room:addPlayerMark(player, string.split(choice, ":")[1], 1)
  end,
})

dengtian:addEffect(fk.DrawNCards, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("ofl__dengtian_draw") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    data.n = data.n + player:getMark("ofl__dengtian_draw")
  end,
})

dengtian:addEffect("maxcards", {
  correct_func = function (self, player)
    return player:getMark("ofl__dengtian_maxcards")
  end,
})

dengtian:addEffect(fk.DamageCaused, {
  can_refresh = function (self, event, target, player, data)
    if target == player and player:getMark("ofl__dengtian_damage") > 0 then
      local damage_events = player.room.logic:getEventsOfScope(GameEvent.Damage, 1, function (e)
        return e.data.from == player
      end, player.HistoryTurn)
      return #damage_events == 1 and damage_events[1].data == data
    end
  end,
  on_refresh = function (self, event, target, player, data)
    data:changeDamage(player:getMark("ofl__dengtian_damage"))
  end,
})

return dengtian
