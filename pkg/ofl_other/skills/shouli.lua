local shouli = fk.CreateSkill {
  name = "ofl__shouli",
}

Fk:loadTranslationTable{
  ["ofl__shouli"] = "狩骊",
  [":ofl__shouli"] = "游戏开始时，所有其他角色随机获得1枚“狩骊”标记。<br>"..
  "每回合各限一次，你可以：1.移动一名其他角色的所有“骏”至其上家或下家，视为使用或打出一张无距离次数限制的【杀】；"..
  "2.移动一名其他角色的所有“骊”至其上家或下家，视为使用或打出一张【闪】。<br>"..
  "“狩骊”标记包括4枚“骊”和3枚“骏”，获得“骏”/“骊”时废除装备区的进攻/防御坐骑栏，失去所有“骏”/“骊”时恢复之。<br>"..
  "若你的“骏”数大于0，你与其他角色的距离-1；大于1，摸牌阶段，你多摸一张牌；大于2，当你使用【杀】指定目标后，该角色本回合非锁定技失效。<br>"..
  "若你的“骊”数大于0，其他角色与你的距离+1；大于1，摸牌阶段，你多摸一张牌；大于2，你造成或受到的伤害均视为雷电伤害；大于3，你造成或受到的伤害+1。<br>"..
  "当你受到属性伤害或【南蛮入侵】、【万箭齐发】造成的伤害后，你的所有“骏”移动至你上家，所有“骊”移动至你下家。",

  ["#ofl__shouli"] = "狩骊：移动一名其他角色的所有“骏”/“骊”，视为使用或打出【杀】/【闪】",
  ["@ofl__jun"] = "骏",
  ["@ofl__li"] = "骊",
  ["#ofl__shouli-move"] = "狩骊：选择一名有%arg标记的其他角色，将其标记移动至其上家或下家",
  ["@@ofl__shouli_tieji-turn"] = "非锁定技失效",

  ["$ofl__shouli1"] = "饲骊胡肉，饮骥虏血，一骑可定万里江山！",
  ["$ofl__shouli2"] = "折兵为弭，纫甲为服，此箭可狩在野之龙！",
}

local U = require "packages/offline/ofl_util"

local getHorse = function (player, mark, n)
  local room = player.room
  if player.dead then return end
  local old = player:getMark(mark)
  room:setPlayerMark(player, mark, old + n)
  if old == 0 then
    local slot = (mark == "@ofl__jun") and Player.OffensiveRideSlot or Player.DefensiveRideSlot
    room:abortPlayerArea(player, slot)
  else
    room.logic:trigger(U.OflShouliMarkChanged, player, {n = old + n})
  end
end

local loseAllHorse = function (player, mark)
  local room = player.room
  room:setPlayerMark(player, mark, 0)
  local slot = (mark == "@ofl__jun") and Player.OffensiveRideSlot or Player.DefensiveRideSlot
  room:resumePlayerArea(player, slot)
end

shouli:addEffect("viewas", {
  pattern = "slash,jink",
  prompt = "#ofl__shouli",
  interaction = function(self, player)
    local all_names = player:getViewAsCardNames(shouli.name, {"slash", "jink"}, nil, player:getTableMark("ofl__shouli-turn"))
    local names = {}
    if table.contains(all_names, "slash") and table.find(Fk:currentRoom().alive_players, function(p)
      return p ~= player and p:getMark("@ofl__jun") > 0
    end) then
      table.insert(names, "slash")
    end
    if table.contains(all_names, "jink") and table.find(Fk:currentRoom().alive_players, function(p)
      return p ~= player and p:getMark("@ofl__li") > 0
    end) then
      table.insert(names, "jink")
    end
    if #names == 0 then return end
    return UI.ComboBox {choices = names}
  end,
  view_as = function(self, player)
    if self.interaction.data == nil then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = shouli.name
    return card
  end,
  before_use = function(self, player, use)
    local room = player.room
    use.extraUse = true
    local mark = (use.card.trueName == "slash") and "@ofl__jun" or "@ofl__li"
    room:addTableMark(player, "ofl__shouli-turn", use.card.name)
    local targets = table.filter(room:getOtherPlayers(player, false), function(p)
      return p:getMark(mark) > 0
    end)
    if #targets == 0 then return shouli.name end
    local success, dat = room:askToUseActiveSkill(player, {
      skill_name = "ofl__shouli_active",
      prompt = "#ofl__shouli-move:::"..mark,
      cancelable = false,
      extra_data = {
        mark = mark,
      },
      no_indicate = true,
    })
    if not (success and dat) then
      dat = {}
      dat.targets = {targets[1], targets[1]:getNextAlive()}
    end
    local n = dat.targets[1]:getMark(mark)
    loseAllHorse (dat.targets[1], mark)
    getHorse (dat.targets[2], mark, n)
  end,
  enabled_at_play = function(self, player)
    return table.find(Fk:currentRoom().alive_players, function(p)
      return p ~= player and p:getMark("@ofl__jun") > 0
    end)
  end,
  enabled_at_response = function(self, player)
    local all_names = player:getViewAsCardNames(shouli.name, {"slash", "jink"}, nil, player:getTableMark("ofl__shouli-turn"))
    if table.contains(all_names, "slash") and table.find(Fk:currentRoom().alive_players, function(p)
      return p ~= player and p:getMark("@ofl__jun") > 0
    end) then
      return true
    end
    if table.contains(all_names, "jink") and table.find(Fk:currentRoom().alive_players, function(p)
      return p ~= player and p:getMark("@ofl__li") > 0
    end) then
      return true
    end
  end,
})

shouli:addEffect(fk.GameStart, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(shouli.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local horse = {"@ofl__jun", "@ofl__jun", "@ofl__jun", "@ofl__li", "@ofl__li", "@ofl__li", "@ofl__li"}
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if not player.dead and not p.dead and #horse > 0 then
        local mark = table.remove(horse, math.random(1, #horse))
        getHorse (p, mark, 1)
      end
    end
  end,
})

shouli:addEffect(fk.DrawNCards, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(shouli.name) and target == player and
      (player:getMark("@ofl__jun") > 1 or player:getMark("@ofl__li") > 1)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local n = 0
    if player:getMark("@ofl__jun") > 1 then
      n = n + 1
    end
    if player:getMark("@ofl__li") > 1 then
      n = n + 1
    end
    data.n = data.n + n
  end,
})

shouli:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shouli.name) and
      data.card.trueName == "slash" and player:getMark("@ofl__jun") > 2
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(data.to, MarkEnum.UncompulsoryInvalidity .. "-turn")
    room:addPlayerMark(data.to, "@@ofl__shouli_tieji-turn")
  end,
})

shouli:addEffect(fk.Damaged, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shouli.name) and
      (data.damageType ~= fk.NormalDamage or (data.card and table.contains({"savage_assault", "archery_attack"}, data.card.name))) and
      (player:getMark("@ofl__jun") > 0 or player:getMark("@ofl__li") > 0) and player:getNextAlive() ~= player
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local jun = player:getMark("@ofl__jun")
    if jun > 0 then
      loseAllHorse (player, "@ofl__jun")
      getHorse (player:getLastAlive(), "@ofl__jun", jun)
    end
    local li = player:getMark("@ofl__li")
    if li > 0 then
      loseAllHorse (player, "@ofl__li")
      getHorse (player:getNextAlive(), "@ofl__li", li)
    end
  end,
})

local spec = {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shouli.name) and player:getMark("@ofl__li") > 2
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local n = player:getMark("@ofl__li")
    if n > 2 then
      data.damageType = fk.ThunderDamage
    end
    if n > 3 then
      data:changeDamage(1)
    end
  end,
}
shouli:addEffect(fk.DamageCaused, spec)
shouli:addEffect(fk.DamageInflicted, spec)

shouli:addEffect("distance", {
  correct_func = function(self, from, to)
    local n = 0
    if from:hasSkill(shouli.name) and from:getMark("@ofl__jun") > 0 then
      n = n - 1
    end
    if to:hasSkill(shouli.name) and to:getMark("@ofl__li") > 0 then
      n = n + 1
    end
    return n
  end,
})

shouli:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card)
    return card and table.contains(card.skillNames, shouli.name)
  end,
  bypass_distances = function(self, player, skill, card)
    return card and table.contains(card.skillNames, shouli.name)
  end,
})

return shouli
