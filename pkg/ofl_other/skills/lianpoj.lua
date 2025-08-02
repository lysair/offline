local lianpoj = fk.CreateSkill {
  name = "lianpoj",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["lianpoj"] = "炼魄",
  [":lianpoj"] = "锁定技，若场上的最大阵营为：<br>反贼，其他角色手牌上限-1，所有角色出牌阶段使用【杀】次数上限+1、攻击范围+1；<br>"..
  "主忠，其他角色不能对除其以外的角色使用【桃】；<br>多个最大阵营，其他角色死亡后，伤害来源摸两张牌或回复1点体力。<br>"..
  "每轮开始时，你展示一张未加入游戏的身份牌或一张已死亡角色的身份牌，本轮视为该阵营角色数+1。",

  ["@lianpoj"] = "炼魄",
  ["@lianpoj-round"] = "炼魄增加",
  ["#lianpoj-choice"] = "炼魄：选择本轮视为增加的一个身份",
  ["#LianpojAddRole"] = "“炼魄”本轮视为人数+1的身份是：%arg",
  ["lianpoj1"] = "主忠",
  ["lianpoj2"] = "反",
  ["lianpoj3"] = "内",

  ["$lianpoj1"] = "圣人伏阳汞炼魄，飞阴铅拘魂。",
  ["$lianpoj2"] = "荡荡古今魂，湛湛紫云天。",
  ["$lianpoj3"] = "北辰居其所，谁人可囊血射之？",
  ["$lianpoj4"] = "大火在中，其明胜月，今邀诸君共掇。",
}

---@param player ServerPlayer
local function UpdateLianpo(player)
  local room = player.room
  local exist_roles = table.map(room.alive_players, function(p)
    return p.role
  end)
  if room:getBanner("@lianpoj-round") then
    table.insertTable(exist_roles, room:getBanner("@lianpoj-round"))
  end
  local rolos = {0, 0, 0}
  for _, role in ipairs(exist_roles) do
    if role == "lord" or role == "loyalist" then
      rolos[1] = rolos[1] + 1
    elseif role == "rebel" then
      rolos[2] = rolos[2] + 1
    elseif role == "renegade" then
      rolos[3] = rolos[3] + 1
    end
  end
  local max_num = 0
  for i = 1, 3 do
    max_num = math.max(max_num, rolos[i])
  end
  local max_roles = {}
  for i = 1, 3 do
    if rolos[i] == max_num then
      table.insert(max_roles, "lianpoj"..i)
    end
  end
  room:setPlayerMark(player, "@lianpoj", max_roles)
end

local spec = {
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(lianpoj.name, true)
  end,
  on_refresh = function(self, event, target, player, data)
    UpdateLianpo(player)
  end,
}

lianpoj:addEffect(fk.RoundStart, {
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(lianpoj.name)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, lianpoj.name)
    player:broadcastSkillInvoke(lianpoj.name, math.random(1, 2))
    local all_roles = {"lord", "loyalist", "rebel", "renegade"}
    local rolesMap = {["lord"] = 0, ["loyalist"] = 0, ["rebel"] = 0, ["renegade"] = 0}
    if room:isGameMode("role_mode") then
      rolesMap = {["lord"] = 1, ["loyalist"] = 3, ["rebel"] = 4, ["renegade"] = 2}
      for _, p in ipairs(room.players) do
        if rolesMap[p.role] then
          rolesMap[p.role] = math.max(0, rolesMap[p.role] - 1)
        end
      end
    end
    for _, p in ipairs(room.players) do
      if p.dead and table.contains(all_roles, p.role) then
        rolesMap[p.role] = rolesMap[p.role] + 1
      end
    end
    if room:getBanner("@lianpoj-round") then
      for _, p in ipairs(room:getBanner("@lianpoj-round")) do
        if rolesMap[p.role] then
          rolesMap[p.role] = rolesMap[p.role] - 1
        end
      end
    end
    local choices = {}
    for _, role in ipairs(all_roles) do
      if rolesMap[role] > 0 then
        table.insert(choices, role)
      end
    end
    if #choices == 0 then return end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = lianpoj.name,
      prompt = "#lianpoj-choice",
      all_choices = all_roles,
    })
    room:sendLog{
      type = "#LianpojAddRole",
      arg = choice,
      toast = true,
    }
    local banner = room:getBanner("@lianpoj-round") or {}
    table.insert(banner, choice)
    room:setBanner("@lianpoj-round", banner)
    UpdateLianpo(player)
  end,

  can_refresh = spec.can_refresh,
  on_refresh = spec.on_refresh,
})

lianpoj:addEffect(fk.EnterDying, {
  can_refresh = function (self, event, target, player, data)
    return player:hasSkill(lianpoj.name) and table.contains(player:getTableMark("@lianpoj"), "lianpoj1")
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(lianpoj.name, 3)
    room:notifySkillInvoked(player, lianpoj.name, "offensive")
  end
})

lianpoj:addEffect(fk.Deathed, {
  anim_type = "special",
  can_trigger = function (self, event, target, player, data)
    return #player:getTableMark("@lianpoj") > 1 and data.killer and not data.killer.dead
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local choices = {"draw2"}
    if data.killer:isWounded() then
      table.insert(choices, "recover")
    end
    local choice = room:askToChoice(data.killer, {
      choices = choices,
      skill_name = lianpoj.name
    })
    if choice == "draw2" then
      data.killer:drawCards(2, lianpoj.name)
    else
      room:recover{
        who = data.killer,
        num = 1,
        recoverBy = data.killer,
        skillName = lianpoj.name,
      }
    end
  end,
})

lianpoj:addEffect(fk.RoundEnd, spec)
lianpoj:addEffect(fk.GameStart, spec)
lianpoj:addEffect(fk.GameOverJudge, spec)
lianpoj:addEffect(fk.AfterPlayerRevived, spec)

lianpoj:addAcquireEffect(function (self, player, is_start)
  UpdateLianpo(player)
end)

lianpoj:addLoseEffect(function (self, player, is_start)
  player.room:setPlayerMark(player, "@lianpoj", 0)
end)

lianpoj:addEffect("maxcards", {
  correct_func = function(self, player)
    return - #table.filter(Fk:currentRoom().alive_players, function(p)
      return table.contains(p:getTableMark("@lianpoj"), "lianpoj2") and p ~= player
    end)
  end,
})

lianpoj:addEffect("targetmod", {
  residue_func = function(self, player, skill, scope)
    if skill.trueName == "slash_skill" and scope == Player.HistoryPhase then
      local n = 0
      for _, p in ipairs(Fk:currentRoom().alive_players) do
        if table.contains(p:getTableMark("@lianpoj"), "lianpoj2") then
          n = n + 1
        end
      end
      return n
    end
  end,
})

lianpoj:addEffect("atkrange", {
  correct_func = function (self, from, to)
    local n = 0
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      if table.contains(p:getTableMark("@lianpoj"), "lianpoj2") then
        n = n + 1
      end
    end
    return n
  end,
})

lianpoj:addEffect("prohibit", {
  is_prohibited = function (self, from, to, card)
    if card and card.name == "peach" and from and from ~= to and to.dying then
      return table.find(Fk:currentRoom().alive_players, function(p)
        return table.contains(p:getTableMark("@lianpoj"), "lianpoj1") and p ~= from
      end)
    end
  end,
})

return lianpoj
