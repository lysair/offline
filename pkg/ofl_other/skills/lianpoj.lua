local lianpoj = fk.CreateSkill {
  name = "lianpoj"
}

Fk:loadTranslationTable{
  ['lianpoj'] = '炼魄',
  ['@lianpoj'] = '炼魄',
  ['lianpoj1'] = '主忠',
  ['@lianpoj_add'] = '炼魄增加',
  ['#lianpoj-choice'] = '炼魄：选择本轮视为增加的一个身份',
  ['#LianpojAddRole'] = '“炼魄”本轮视为人数+1的身份是：%arg',
  ['lianpoj2'] = '反',
  [':lianpoj'] = '锁定技，若场上的最大阵营为：<br>反贼，其他角色手牌上限-1，所有角色出牌阶段使用【杀】次数上限+1、攻击范围+1；<br>主忠，其他角色不能对除其以外的角色使用【桃】；<br>多个最大阵营，其他角色死亡后，伤害来源摸两张牌或回复1点体力。<br>每轮开始时，你展示一张未加入游戏的身份牌或一张已死亡角色的身份牌，本轮视为该阵营角色数+1。',
  ['$lianpoj1'] = '圣人伏阳汞炼魄，飞阴铅拘魂。',
  ['$lianpoj2'] = '荡荡古今魂，湛湛紫云天。',
  ['$lianpoj3'] = '北辰居其所，谁人可囊血射之？',
  ['$lianpoj4'] = '大火在中，其明胜月，今邀诸君共掇。',
}

lianpoj:addEffect(fk.RoundStart, {
  global = false,
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(lianpoj.name) and true
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
    if type(room:getBanner("@lianpoj_add")) == "table" then
      for _, p in ipairs(room:getBanner("@lianpoj_add")) do
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
      all_choices = all_roles
    })
    room:sendLog{
      type = "#LianpojAddRole",
      arg = choice,
      toast = true,
    }
    local banner = type(room:getBanner("@lianpoj_add")) == "table" and room:getBanner("@lianpoj_add") or {}
    table.insert(banner, choice)
    room:setBanner("@lianpoj_add", banner)
    UpdateLianpo(player)
  end
})

lianpoj:addEffect(fk.EnterDying, {
  global = false,
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(lianpoj.name) and table.contains(player:getTableMark("@lianpoj"), "lianpoj1")
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(lianpoj.name, 3)
    room:notifySkillInvoked(player, lianpoj.name)
  end
})

lianpoj:addEffect(fk.Deathed, {
  global = false,
  can_trigger = function (self, event, target, player, data)
    return #player:getTableMark("@lianpoj") > 1 and data.damage and data.damage.from and not data.damage.from.dead
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local p = data.damage.from
    local choices = {"draw2"}
    if p:isWounded() then
      table.insert(choices, "recover")
    end
    local choice = room:askToChoice(p, {
      choices = choices,
      skill_name = lianpoj.name
    })
    if choice == "draw2" then
      p:drawCards(2, lianpoj.name)
    else
      room:recover({
        who = p,
        num = 1,
        recoverBy = p,
        skillName = lianpoj.name
      })
    end
  end
})

lianpoj:addEffect(fk.RoundStart, {
  global = true,
  can_refresh = function(self, event, target, player, data)
    return type(player.room:getBanner("@lianpoj_add")) == "table"
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setBanner("@lianpoj_add", 0)
    for _, p in ipairs(room.alive_players) do
      if p:hasSkill(lianpoj.name, true) then
        UpdateLianpo(p)
      end
    end
  end,
})

lianpoj:addEffect(fk.GameStart, {
  global = false,
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(lianpoj.name, true)
  end,
  on_refresh = function(self, event, target, player, data)
    UpdateLianpo(player)
  end
})

lianpoj:addEffect(fk.GameOverJudge, {
  global = false,
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(lianpoj.name, true)
  end,
  on_refresh = function(self, event, target, player, data)
    UpdateLianpo(player)
  end
})

lianpoj:addEffect(fk.AfterPlayerRevived, {
  global = false,
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(lianpoj.name, true)
  end,
  on_refresh = function(self, event, target, player, data)
    UpdateLianpo(player)
  end
})

lianpoj:addEffect(fk.RoundEnd, {
  global = false,
  can_refresh = function(self, event, target, player, data)
    return type(player.room:getBanner("@lianpoj_add")) == "table"
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.RoundEnd then
      room:setBanner("@lianpoj_add", 0)
      for _, p in ipairs(room.alive_players) do
        if p:hasSkill(lianpoj.name, true) then
          UpdateLianpo(p)
        end
      end
    else
      UpdateLianpo(player)
    end
  end,
})

lianpoj:addEffect("on_acquire", {
  on_acquire = function (self, player, is_start)
    UpdateLianpo(player)
  end,
})

lianpoj:addEffect("on_lose", {
  on_lose = function (self, player, is_death)
    player.room:setPlayerMark(player, "@lianpoj", 0)
  end,
})

local lianpoj_maxcards = fk.CreateSkill { name = "#lianpoj_maxcards" }
lianpoj_maxcards:addEffect("maxcards", {
  frequency = Skill.Compulsory,
  correct_func = function(self, player)
    local n = 0
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      if table.contains(p:getTableMark("@lianpoj"), "lianpoj2") and p ~= player then
        n = n - 1
      end
    end
    return n
  end,
})

local lianpoj_targetmod = fk.CreateSkill { name = "#lianpoj_targetmod" }
lianpoj_targetmod:addEffect("targetmod", {
  frequency = Skill.Compulsory,
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

local lianpoj_attackrange = fk.CreateSkill { name = "#lianpoj_attackrange" }
lianpoj_attackrange:addEffect("atkrange", {
  frequency = Skill.Compulsory,
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

local lianpoj_prohibit = fk.CreateSkill { name = "#lianpoj_prohibit" }
lianpoj_prohibit:addEffect("prohibit", {
  is_prohibited = function (self, from, to, card)
    if card and card.name == "peach" and from ~= to and to.dying then
      return table.find(Fk:currentRoom().alive_players, function(p)
        return table.contains(p:getTableMark("@lianpoj"), "lianpoj1") and p ~= from
      end)
    end
  end,
})

return lianpoj
