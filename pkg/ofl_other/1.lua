
local liuhong = General(extension, "rom__liuhong", "qun", 4)
local rom__zhenglian = fk.CreateTriggerSkill{
  name = "rom__zhenglian",
  events = {fk.EventPhaseStart},
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start 
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = room:getOtherPlayers(player)
    room:doIndicate(player.id, table.map(targets, Util.IdMapper))
    local prompt = "#rom__zhenglian-ask:" .. player.id
    local tos = {}
    for _, p in ipairs(targets) do
      if player.dead then return end
      if not p.dead then
        local card = room:askForCard(p, 1, 1, true, self.name, true, nil, prompt)
        if #card > 0 then
          room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonGive, self.name, nil, false, player.id)
        else
          table.insert(tos, p)
        end
      end
    end
    local num = #tos
    tos = table.map(table.filter(tos, function(p) return not p:isNude() end), Util.IdMapper)
    local to = room:askForChoosePlayers(player, tos, 1, 1, "#rom__zhenglian-discard:::" .. num, self.name, true)
    if #to > 0 then
      room:askForDiscard(room:getPlayerById(to[1]), num, num, true, self.name, false)
    end
  end
}
Fk:loadTranslationTable{
  ["rom__zhenglian"] = "征敛",
  [":rom__zhenglian"] = "准备阶段，你可以令所有其他角色依次选择是否交给你一张牌。所有角色选择完毕后，你可以令一名选择否的角色弃置X张牌（X为选择否的角色数）。",
  ["#rom__zhenglian-ask"] = "征敛：交给 %src 一张牌，否则有可能被其要求弃牌",
  ["#rom__zhenglian-discard"] = "征敛：你可以令一名选择否的角色弃置 %arg 张牌",
}

local ofl__godmachao = General(extension, "ofl__godmachao", "god", 4)
local getHorse = function (room, player, mark, n)
  local old = player:getMark(mark)
  room:setPlayerMark(player, mark, old + n)
  if old == 0 then
    local slot = (mark == "@ofl__jun") and Player.OffensiveRideSlot or Player.DefensiveRideSlot
    room:abortPlayerArea(player, slot)
  else
    room.logic:trigger("fk.OflShouliMarkChanged", player, {n = old + n})
  end
end
local loseAllHorse = function (room, player, mark)
  room:setPlayerMark(player, mark, 0)
  local slot = (mark == "@ofl__jun") and Player.OffensiveRideSlot or Player.DefensiveRideSlot
  room:resumePlayerArea(player, slot)
end
local ofl__shouli = fk.CreateViewAsSkill{
  name = "ofl__shouli",
  pattern = "slash,jink",
  prompt = "#ofl__shouli-promot",
  interaction = function()
    local names = {}
    local pat = Fk.currentResponsePattern
    if ((pat == nil and not Self:prohibitUse(Fk:cloneCard("slash"))) or (pat and Exppattern:Parse(pat):matchExp("slash")))
    and Self:getMark("ofl__shouli_slash-turn") == 0
    and table.find(Fk:currentRoom().alive_players, function(p) return p ~= Self and p:getMark("@ofl__jun") > 0 end) then
      table.insert(names, "slash")
    end
    if pat and Exppattern:Parse(pat):matchExp("jink")
    and Self:getMark("ofl__shouli_jink-turn") == 0
    and table.find(Fk:currentRoom().alive_players, function(p) return p ~= Self and p:getMark("@ofl__li") > 0 end) then
      table.insert(names, "jink")
    end
    if #names == 0 then return end
    return UI.ComboBox {choices = names}
  end,
  view_as = function(self)
    if self.interaction.data == nil then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = self.name
    return card
  end,
  before_use = function(self, player, use)
    local room = player.room
    use.extraUse = true
    local mark = (use.card.trueName == "slash") and "@ofl__jun" or "@ofl__li"
    room:addPlayerMark(player, "ofl__shouli_"..use.card.trueName.."-turn")
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return p:getMark(mark) > 0
    end)
    if #targets > 0 then
      local tos = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1, "#ofl__shouli-horse:::" .. mark, self.name, false, true)
      if #tos > 0 then
        local to = room:getPlayerById(tos[1])
        local next = to:getNextAlive()
        local last = to:getLastAlive()
        local choice = room:askForChoice(player, {"ofl__shouli_next:"..next.id, "ofl__shouli_last:"..last.id}, self.name,
        "#ofl__shouli-move::"..to.id..":"..mark)
        local receiver = choice:startsWith("ofl__shouli_next") and next or last
        local n = to:getMark(mark)
        loseAllHorse (room, to, mark)
        getHorse (room, receiver, mark, n)
      end
    end
  end,
  enabled_at_play = function(self, player)
    return player:getMark("ofl__shouli_slash-turn") == 0 and table.find(Fk:currentRoom().alive_players, function(p)
      return p ~= player and p:getMark("@ofl__jun") > 0
    end)
  end,
  enabled_at_response = function(self, player)
    local pat = Fk.currentResponsePattern
    if not pat then return end
    if Exppattern:Parse(pat):matchExp("slash") and player:getMark("ofl__shouli_slash-turn") == 0 then
      return table.find(Fk:currentRoom().alive_players, function(p)
        return p ~= player and p:getMark("@ofl__jun") > 0
      end)
    end
    if Exppattern:Parse(pat):matchExp("jink") and player:getMark("ofl__shouli_jink-turn") == 0 then
      return table.find(Fk:currentRoom().alive_players, function(p)
        return p ~= player and p:getMark("@ofl__li") > 0
      end)
    end
  end,
}
local ofl__shouli_trigger = fk.CreateTriggerSkill{
  name = "#ofl__shouli_trigger",
  events = {fk.GameStart, fk.DrawNCards, fk.TargetSpecified, fk.Damaged,fk.DamageInflicted, fk.DamageCaused},
  mute = true,
  main_skill = ofl__shouli,
  can_trigger = function(self, event, target, player, data)
    if event == fk.GameStart then
      return player:hasSkill(self)
    elseif event == fk.DrawNCards then
      return player:hasSkill(self) and target == player and (player:getMark("@ofl__jun") > 1 or player:getMark("@ofl__li") > 1)
    elseif event == fk.TargetSpecified then
      return target == player and player:hasSkill(self) and data.card.trueName == "slash" and player:getMark("@ofl__jun") > 2
    elseif event == fk.Damaged then
      return player:hasSkill(self) and target == player and (data.damageType ~= fk.NormalDamage
      or (data.card and (data.card.name == "savage_assault" or data.card.name == "archery_attack")))
      and (player:getMark("@ofl__jun") > 0 or player:getMark("@ofl__li") > 0) and player:getNextAlive() ~= player
    else
      return player:hasSkill(self) and target == player and player:getMark("@ofl__li") > 2
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(ofl__shouli.name)
    room:notifySkillInvoked(player, ofl__shouli.name)
    if event == fk.GameStart then
      local horse = {"@ofl__jun", "@ofl__jun", "@ofl__jun", "@ofl__li", "@ofl__li", "@ofl__li", "@ofl__li"}
      for _, p in ipairs(room:getOtherPlayers(player)) do
        if not player.dead and not p.dead and #horse > 0 then
          local mark = table.remove(horse, math.random(1, #horse))
          getHorse (room, p, mark, 1)
        end
      end
    elseif event == fk.DrawNCards then
      local n = 0
      if player:getMark("@ofl__jun") > 1 then n = n + 1 end
      if player:getMark("@ofl__li") > 1 then n = n + 1 end
      data.n = data.n + n
    elseif event == fk.TargetSpecified then
      local to = room:getPlayerById(data.to)
      room:addPlayerMark(to, MarkEnum.UncompulsoryInvalidity .. "-turn")
      room:addPlayerMark(to, "@@ofl__shouli_tieji-turn")
    elseif event == fk.Damaged then
      local jun = player:getMark("@ofl__jun")
      if jun > 0 then
        loseAllHorse (room, player, "@ofl__jun")
        getHorse (room, player:getLastAlive(), "@ofl__jun", jun)
      end
      local li = player:getMark("@ofl__li")
      if li > 0 then
        loseAllHorse (room, player, "@ofl__li")
        getHorse (room, player:getNextAlive(), "@ofl__li", li)
      end
    else
      local n = player:getMark("@ofl__li")
      if n > 2 then
        data.damageType = fk.ThunderDamage
      end
      if n > 3 then
        data.damage = data.damage + 1
      end
    end
  end,
}
local ofl__shouli_distance = fk.CreateDistanceSkill{
  name = "#ofl__shouli_distance",
  correct_func = function(self, from, to)
    if from:hasSkill(self) and from:getMark("@ofl__jun") > 0 then
      return -1
    end
    if to:hasSkill(self) and to:getMark("@ofl__li") > 0 then
      return 1
    end
  end,
}
local ofl__shouli_targetmod = fk.CreateTargetModSkill{
  name = "#ofl__shouli_targetmod",
  bypass_times = function(self, player, skill, scope, card)
    return card and table.contains(card.skillNames, "ofl__shouli")
  end,
  bypass_distances = function(self, player, skill, card)
    return card and table.contains(card.skillNames, "ofl__shouli")
  end,
}
-- 耦了!
local ofl__hengwu = fk.CreateTriggerSkill{
  name = "ofl__hengwu",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {"fk.OflShouliMarkChanged"},
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self)
  end,
  on_use = function (self, event, target, player, data)
    player:drawCards(data.n, self.name)
  end,
}
Fk:loadTranslationTable{
  ["ofl__shouli"] = "狩骊",
  [":ofl__shouli"] = "①游戏开始时，所有其他角色随机获得1枚“狩骊”标记。"..
  "<br>②每回合各限一次，你可以选择一项：1.移动一名其他角色的所有“骏”至其上家或下家，并视为使用或打出一张无距离和次数限制的【杀】；2.移动一名其他角色的"..
  "所有“骊”至其上家或下家，并视为使用或打出一张【闪】。"..
  "<br>③“狩骊”标记包括4枚“骊”和3枚“骏”，获得“骏”/“骊”时废除装备区的进攻/防御坐骑栏，失去所有“骏”/“骊”时恢复之。"..
  "<br>④若你的“骏”数量大于0，你与其他角色的距离-1；大于1，摸牌阶段，你多摸一张牌；大于2，当你使用【杀】指定目标后，该角色本回合非锁定技失效。"..
  "<br>⑤若你的“骊”数量大于0，其他角色与你的距离+1；大于1，摸牌阶段，你多摸一张牌；大于2，你造成或受到的伤害均视为雷电伤害；大于3，你造成或受到的伤害+1。"..
  "<br>⑥当你受到属性伤害或【南蛮入侵】、【万箭齐发】造成的伤害后，你的所有“骏”移动至你上家，所有“骊”移动至你下家。",
  ["ofl__hengwu"] = "横骛",
  [":ofl__hengwu"] = "锁定技，有“骏”/“骊”的角色获得“骏”/“骊”后，你摸X张牌（X为其拥有该标记的数量）。",

  ["@ofl__jun"] = "骏",
  ["@ofl__li"] = "骊",
  ["@@ofl__shouli_tieji-turn"] = "狩骊封技",
  ["ofl__shouli_last"] = "上家:%src",
  ["ofl__shouli_next"] = "下家:%src",
  ["#ofl__shouli-promot"] = "狩骊：移动一名其他角色的所有“骏”/“骊”，视为使用或打出【杀】/【闪】",
  ["#ofl__shouli-horse"] = "狩骊：选择一名有 %arg 标记的其他角色",
  ["#ofl__shouli-move"] = "狩骊：将 %dest 所有 %arg 标记移动至其上家或下家",

  ["$ofl__shouli1"] = "饲骊胡肉，饮骥虏血，一骑可定万里江山！",
  ["$ofl__shouli2"] = "折兵为弭，纫甲为服，此箭可狩在野之龙！",
  ["$ofl__hengwu1"] = "此身独傲，天下无不可敌之人，无不可去之地！",
  ["$ofl__hengwu2"] = "神威天降，世间无不可驭之雷，无不可降之马！",
}

local sgsh__huanhua_blacklist = {
  "zuoci", "ol_ex__zuoci", "js__xushao", "shichangshi", "starsp__xiahoudun"
}

local nanhualaoxian = General(extension, "sgsh__nanhualaoxian", "qun", 3)
local sgsh__jidao = fk.CreateTriggerSkill{
  name = "sgsh__jidao",
  anim_type = "drawcard",
  events = {fk.PropertyChange},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and player.general == "sgsh__nanhualaoxian" and data.deputyGeneral and target.deputyGeneral ~= ""
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
}
local sgsh__feisheng = fk.CreateTriggerSkill{
  name = "sgsh__feisheng",
  anim_type = "drawcard",
  events = {fk.PropertyChange},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.deputyGeneral == "sgsh__nanhualaoxian" and
      data.deputyGeneral
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choices = {"draw2"}
    if player:isWounded() then
      table.insert(choices, "recover")
    end
    local choice = room:askForChoice(player, choices, self.name)
    if choice == "draw2" then
      player:drawCards(2, self.name)
    else
      room:recover({
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name
      })
    end
  end,
}
local sgsh__jinghe = fk.CreateTriggerSkill{
  name = "sgsh__jinghe",
  anim_type = "support",
  events = {fk.BeforePropertyChange},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.deputyGeneral and data.deputyGeneral ~= "" and not target.dead
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#sgsh__jinghe-invoke::"..target.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    local generals = room:getNGenerals(2)
    local general = room:askForGeneral(target, generals, 1, true)
    if general == nil then
      general = table.random(generals)
    end
    table.removeOne(generals, general)
    room:returnToGeneralPile(generals)
    data.deputyGeneral = general
  end,
}
local sgsh__huanhua = fk.CreateTriggerSkill{
  name = "sgsh__huanhua",
  mute = true,
  frequency = Skill.Compulsory,
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and not player.dead
  end,
  on_trigger = function(self, event, target, player, data)  --假装不是技能
    local room = player.room
    for i = 1, data.damage do
      if player.dead then break end
      local generals = table.filter(room.general_pile, function(name)
        return not table.contains(sgsh__huanhua_blacklist, name)
      end)
      local general = table.random(generals)
      table.removeOne(room.general_pile, general)
      if player.deputyGeneral ~= "" then
        room:returnToGeneralPile({player.deputyGeneral})
      end
      room:changeHero(player, general, false, true, true, false, false)
    end
  end,
}
nanhualaoxian:addSkill(sgsh__jidao)
nanhualaoxian:addSkill(sgsh__feisheng)
nanhualaoxian:addSkill(sgsh__jinghe)
nanhualaoxian:addSkill(sgsh__huanhua)
Fk:loadTranslationTable{
  ["sgsh__nanhualaoxian"] = "幻南华老仙",
  ["#sgsh__nanhualaoxian"] = "虚步太清",
  ["illustrator:sgsh__nanhualaoxian"] = "鬼画府",

  ["sgsh__jidao"] = "祭祷",
  [":sgsh__jidao"] = "主将技，当一名角色的副将被移除时，你可以摸一张牌。",
  ["sgsh__feisheng"] = "飞升",
  [":sgsh__feisheng"] = "副将技，当此武将牌被移除时，你可以回复1点体力或摸两张牌。",
  ["sgsh__jinghe"] = "经合",
  [":sgsh__jinghe"] = "当一名其他角色获得副将武将牌前，你可以令其改为观看两张未加入游戏的武将牌并选择一张作为副将。",
  ["sgsh__huanhua"] = "幻化",
  [":sgsh__huanhua"] = "锁定技，当一名角色受到1点伤害后，移除其副将，其从未加入游戏的武将牌中随机获得一张作为副将。此技能不会失效。",
  --原本是一个逆天的四将模式，魔改一下
  ["#sgsh__jinghe-invoke"] = "经合：%dest 即将获得随机副将，是否改为其观看两张并选择一张作为副将？",

  ["$sgsh__jidao"] = "含气求道，祸福难料，且与阁下共参之。",
  ["$sgsh__feisheng"] = "蕴气修德，其理易现，容吾为君讲解一二。",
  ["$sgsh__jinghe1"] = "此经所书晦涩难明，吾偶有所悟，愿为君陈之。",
  ["$sgsh__jinghe2"] = "大音希声，大象无形，天理难明，以经合之。",
  ["~sgsh__nanhualaoxian"] = "此理闻所未闻，参不透啊。",
}

local sgsh__zuoci = General(extension, "sgsh__zuoci", "qun", 3)
local sgsh__huashen = fk.CreateActiveSkill{
  name = "sgsh__huashen",
  prompt = "#sgsh__huashen",
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local skills = Fk.generals[target.general]:getSkillNameList()
      if Fk.generals[target.deputyGeneral] then
        table.insertTableIfNeed(skills, Fk.generals[target.deputyGeneral]:getSkillNameList())
      end
      skills = table.filter(skills, function(skill_name)
        local skill = Fk.skills[skill_name]
        return not player:hasSkill(skill, true) and (#skill.attachedKingdom == 0 or table.contains(skill.attachedKingdom, player.kingdom))
      end)
      if #skills > 0 then
        local skill = room:askForChoice(player, skills, self.name, "#sgsh__huashen-choice", true)
        room:setPlayerMark(player, "@sgsh__huashen-turn", skill)
        room:handleAddLoseSkills(player, skill, nil, true, false)
      end
  end,
}
local sgsh__huashen_delay = fk.CreateTriggerSkill {
  name = "#sgsh__huashen_delay",

  refresh_events = {fk.TurnEnd},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@sgsh__huashen-turn") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    local skill = player:getMark("@sgsh__huashen-turn")
    player.room:handleAddLoseSkills(player, "-"..skill, nil, true, true)
  end,
}
local sgsh__xinsheng = fk.CreateTriggerSkill{
  name = "sgsh__xinsheng",
  anim_type = "special",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start and
      player.general == "sgsh__zuoci" and player.deputyGeneral ~= ""
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:returnToGeneralPile({player.deputyGeneral})
    room:changeHero(player, "", false, true, true, false, false)
    if player.dead then return end
    local generals = table.filter(room.general_pile, function(name)
      return not table.contains(sgsh__huanhua_blacklist, name)
    end)
    local general = table.random(generals)
    table.removeOne(room.general_pile, general)
    room:changeHero(player, general, false, true, true, false, false)
  end,
}
sgsh__huashen:addRelatedSkill(sgsh__huashen_delay)
sgsh__zuoci:addSkill(sgsh__huashen)
sgsh__zuoci:addSkill(sgsh__xinsheng)
sgsh__zuoci:addSkill("sgsh__huanhua")
Fk:loadTranslationTable{
  ["sgsh__zuoci"] = "幻左慈",
  ["#sgsh__zuoci"] = "谜之仙人",
  ["illustrator:sgsh__zuoci"] = "JanusLausDeo",

  ["sgsh__huashen"] = "化身",
  [":sgsh__huashen"] = "出牌阶段限一次，你可以选择一名其他角色，声明其武将牌上的一个技能，你获得此技能直到回合结束。",
  ["sgsh__xinsheng"] = "新生",
  [":sgsh__xinsheng"] = "主将技，准备阶段，你可以移除副将，然后随机获得一张未加入游戏的武将牌作为副将。",
  ["#sgsh__huashen"] = "化身：获得一名其他角色武将牌上的一个技能，直到回合结束",
  ["#sgsh__huashen-choice"] = "化身：选择你要获得的技能",
  ["@sgsh__huashen-turn"] = "化身",

  ["$sgsh__huashen1"] = "幻化之术谨之，为政者自当为国为民。",
  ["$sgsh__huashen2"] = "天之政者，不可逆之，逆之，虽胜必衰矣。",
  ["$sgsh__xinsheng1"] = "傍日月，携宇宙，游乎尘垢之外。",
  ["$sgsh__xinsheng2"] = "吾多与天地精神之往来，生即死，死又复生。",
  ["~sgsh__zuoci"] = "万事，皆有因果。",
}

local sgsh__jianggan = General(extension, "sgsh__jianggan", "wei", 3)
local sgsh__daoshu = fk.CreateActiveSkill{
  name = "sgsh__daoshu",
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  prompt = "#sgsh__daoshu",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local suits = {"log_spade", "log_club", "log_heart", "log_diamond"}
    local choice = room:askForChoice(player, suits, self.name)
    room:doBroadcastNotify("ShowToast", Fk:translate(player.general)..Fk:translate("#sgsh__daoshu-chose")..Fk:translate(choice))
    if target:isKongcheng() then
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = self.name,
      }
    else
      target:showCards(target:getCardIds("h"))
      if target.dead then return end
      local cards = table.filter(target:getCardIds("h"), function(id) return Fk:getCardById(id):getSuitString(true) == choice end)
      if #cards == 0 then
        room:damage{
          from = player,
          to = target,
          damage = 1,
          skillName = self.name,
        }
      elseif player.dead or room:askForSkillInvoke(target, self.name, nil, "#sgsh__daoshu-give:"..player.id.."::"..choice) then
        room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonGive, self.name, nil, true, target.id)
      else
        room:damage{
          from = player,
          to = target,
          damage = 1,
          skillName = self.name,
        }
      end
    end
  end,
}
sgsh__jianggan:addSkill(sgsh__daoshu)
sgsh__jianggan:addSkill("weicheng")
Fk:loadTranslationTable{
  ["sgsh__jianggan"] = "蒋干",
  ["sgsh__daoshu"] = "盗书",
  [":sgsh__daoshu"] = "出牌阶段限一次，你可以选择一名其他角色并声明一种花色，其展示所有手牌并选择一项：1.交给你所有你此花色的手牌；2.你对其造成1点伤害。",
  ["#sgsh__daoshu"] = "盗书：声明一种花色，令一名角色选择交给你所有此花色手牌或你对其造成伤害",
  ["#sgsh__daoshu-chose"] = "盗书选择了：",
  ["#sgsh__daoshu-give"] = "盗书：交给%src所有%arg手牌，或点“取消”其对你造成1点伤害",

  ["$sgsh__daoshu1"] = "赤壁之战，我军之患，不足为惧。",
  ["$sgsh__daoshu2"] = "取此机密，简直易如反掌。",
  ["$weicheng_sgsh__jianggan1"] = "公瑾，吾之诚心，天地可鉴。",
  ["$weicheng_sgsh__jianggan2"] = "遥闻芳烈，故来叙阔。",
  ["~sgsh__jianggan"] = "蔡张之罪，非我之过呀！",
}

local sgsh__huaxiong = General(extension, "sgsh__huaxiong", "qun", 4)
local sgsh__yaowu = fk.CreateTriggerSkill{
  name = "sgsh__yaowu",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.DamageCaused, fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card and data.card.trueName == "slash"
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
}
Fk:loadTranslationTable{
  ["sgsh__huaxiong"] = "华雄",
  ["sgsh__yaowu"] = "耀武",
  [":sgsh__yaowu"] = "锁定技，当一名角色对你使用【杀】造成伤害时，或当你使用【杀】造成伤害时，你摸一张牌。",

  ["$sgsh__yaowu1"] = "来将通名，吾刀下不斩无名之辈！",
  ["$sgsh__yaowu2"] = "且看汝比那祖茂潘凤如何？",
  ["~sgsh__huaxiong"] = "错失先机，呃啊！",
}

local sgsh__lisu = General(extension, "sgsh__lisu", "qun", 3)
local sgsh__kuizhul = fk.CreateTriggerSkill{
  name = "sgsh__kuizhul",
  anim_type = "support",
  events = {fk.Damage},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target and target ~= player and not player:isKongcheng() and not target.dead
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askForCard(player, 1, 1, false, self.name, true, ".", "#sgsh__kuizhul-invoke::"..target.id)
    if #card > 0 then
      self.cost_data = card[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:moveCardTo(Fk:getCardById(self.cost_data), Card.PlayerHand, target, fk.ReasonGive, self.name, nil, false, player.id)
    if not player.dead and player:getHandcardNum() > target:getHandcardNum() then
      player:drawCards(1, self.name)
    end
  end,
}
local sgsh__qiaoyan = fk.CreateTriggerSkill{
  name = "sgsh__qiaoyan",
  anim_type = "support",
  events = {fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and player:usedSkillTimes("sgsh__kuizhul", Player.HistoryTurn) > 0 and player:isWounded()
  end,
  on_use = function(self, event, target, player, data)
    player.room:recover({
      who = player,
      num = 1,
      recoverBy = player,
      skillName = self.name,
    })
  end,
}
Fk:loadTranslationTable{
  ["sgsh__lisu"] = "李肃",
  ["sgsh__kuizhul"] = "馈珠",
  [":sgsh__kuizhul"] = "当一名其他角色造成伤害后，你可以交给其一张手牌，然后若其手牌数小于你，你摸一张牌。",
  ["sgsh__qiaoyan"] = "巧言",
  [":sgsh__qiaoyan"] = "一名角色结束阶段，若你本回合发动过〖馈珠〗，你可以回复1点体力。",
  ["#sgsh__kuizhul-invoke"] = "馈珠：你可以交给 %dest 一张手牌",

  ["$sgsh__kuizhul1"] = "宝珠万千，皆予将军一人。",
  ["$sgsh__kuizhul2"] = "馈珠还情，邀买人心。",
  ["$sgsh__qiaoyan1"] = "金银渐欲迷人眼，利字当前诱汝行！",
  ["$sgsh__qiaoyan2"] = "以利驱虎，无往不利！",
  ["~sgsh__lisu"] = "见利忘义，必遭天谴。",
}

local sunchen = General(extension, "ofl__sunchen", "wu", 4)
local ofl__shilus = fk.CreateTriggerSkill{
  name = "ofl__shilus",
  mute = true,
  events = {fk.GameStart, fk.Deathed, fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.EventPhaseStart then
        return player == target and player.phase == Player.Start and not player:isNude() and #player:getTableMark("@&massacre") > 0
      else
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then
      local x = #player:getMark("@&massacre")
      local cards = room:askForDiscard(player, 1, x, true, self.name, true, ".", "#ofl__shilus-cost:::"..tostring(x), true)
      if #cards > 0 then
        self.cost_data = cards
        return true
      end
    elseif event == fk.GameStart then
      return true
    else
      return player.room:askForSkillInvoke(player, self.name, nil, "#ofl__shilus-invoke::"..target.id)
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("shilus")
    if event == fk.EventPhaseStart then
      room:notifySkillInvoked(player, self.name, "drawcard")
      room:throwCard(self.cost_data, self.name, player, player)
      if not player.dead then
        room:drawCards(player, #self.cost_data, self.name)
      end
    else
      room:notifySkillInvoked(player, self.name, "special")
      local cards = {}
      if event == fk.GameStart then
        table.insertTableIfNeed(cards, room:getNGenerals(2))
      elseif event == fk.Deathed then
        room:doIndicate(player.id, {target.id})
        if target.general and target.general ~= "" and target.general ~= "hiddenone" then
          room:findGeneral(target.general)
          table.insert(cards, target.general)
        end
        if target.deputyGeneral and target.deputyGeneral ~= "" and target.deputyGeneral ~= "hiddenone" then
          room:findGeneral(target.deputyGeneral)
          table.insert(cards, target.deputyGeneral)
        end
        if data.damage and data.damage.from == player then
          table.insertTableIfNeed(cards, room:getNGenerals(2))
        end
      end
      if #cards > 0 then
        local generals = player:getTableMark("@&massacre")
        table.insertTableIfNeed(generals, cards)
        room:setPlayerMark(player, "@&massacre", generals)
      end
    end
  end,

  refresh_events = {fk.EventLoseSkill, fk.BuryVictim},
  can_refresh = function(self, event, target, player, data)
    if target == player and player:getMark("@&massacre") ~= 0 then
      if event == fk.EventLoseSkill then
        return data == self
      elseif event == fk.BuryVictim then
        return true
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:returnToGeneralPile(player:getTableMark("@&massacre"))
    room:setPlayerMark(player, "@&massacre", 0)
  end,
}
local ofl__xiongnve = fk.CreateTriggerSkill{
  name = "ofl__xiongnve",
  mute = true,
  events = {fk.EventPhaseStart, fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and player.phase == Player.Play then
      local n = #player:getTableMark("@&massacre")
      if event == fk.EventPhaseStart then
        return n > 0
      else
        return n > 1
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.EventPhaseStart then
      local result = player.room:askForCustomDialog(player, self.name,
        "packages/utility/qml/ChooseGeneralsAndChoiceBox.qml", {
          player:getMark("@&massacre"),
          {"ofl__xiongnve_choice1", "ofl__xiongnve_choice2", "ofl__xiongnve_choice3"},
          "#ofl__xiongnve-chooose",
          {"Cancel"}
        })
      if result ~= "" then
        local reply = json.decode(result)
        if reply.choice ~= "Cancel" then
          self.cost_data = {reply.cards, reply.choice}
          return true
        end
      end
    else
      local result = player.room:askForCustomDialog(player, self.name,
      "packages/utility/qml/ChooseGeneralsAndChoiceBox.qml", {
        player:getMark("@&massacre"),
        {"OK"},
        "#ofl__xiongnve-defence",
        {"Cancel"},
        2,
        2
      })
      if result ~= "" then
        local reply = json.decode(result)
        if reply.choice == "OK" then
          self.cost_data = {reply.cards}
          return true
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("xiongnve")
    if event == fk.EventPhaseStart then
      room:notifySkillInvoked(player, self.name, "offensive")
    else
      room:notifySkillInvoked(player, self.name, "defensive")
    end
    local generals = player:getTableMark("@&massacre")
    for _, name in ipairs(self.cost_data[1]) do
      table.removeOne(generals, name)
    end
    if #generals == 0 then
      room:setPlayerMark(player, "@&massacre", 0)
    else
      room:setPlayerMark(player, "@&massacre", generals)
    end
    room:returnToGeneralPile(self.cost_data[1])
    if event == fk.EventPhaseStart then
      room:setPlayerMark(player, "@ofl__xiongnve_choice-turn", "ofl__xiongnve_effect" .. string.sub(self.cost_data[2], 21, 21))
    elseif event == fk.EventPhaseEnd then
      room:setPlayerMark(player, "@@ofl__xiongnve", 1)
    end
  end,

  refresh_events = {fk.TurnStart},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@@ofl__xiongnve") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@ofl__xiongnve", 0)
  end,
}
local ofl__xiongnve_delay = fk.CreateTriggerSkill{
  name = "#ofl__xiongnve_delay",
  mute = true,
  events = {fk.DamageCaused, fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    if target == player and not player.dead then
      if event == fk.DamageCaused then
        if not data.to.dead then
          local effect_name = player:getMark("@ofl__xiongnve_choice-turn")
          if effect_name == "ofl__xiongnve_effect1" then
            return true
          elseif effect_name == "ofl__xiongnve_effect2" then
            return #data.to:getCardIds("e") > 0 or (not data.to:isKongcheng() and data.to ~= player)
          end
        end
      else
        return player:getMark("@@ofl__xiongnve") > 0 and data.from and data.from ~= player
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("xiongnve")
    if event == fk.DamageCaused then
      room:doIndicate(player.id, {data.to.id})
      local effect_name = player:getMark("@ofl__xiongnve_choice-turn")
      if effect_name == "ofl__xiongnve_effect1" then
        room:notifySkillInvoked(player, "ofl__xiongnve", "offensive")
        data.damage = data.damage + 1
      elseif effect_name == "ofl__xiongnve_effect2" then
        room:notifySkillInvoked(player, "ofl__xiongnve", "control")
        local flag =  data.to == player and "e" or "he"
        local card = room:askForCardChosen(player, data.to, flag, self.name)
        room:obtainCard(player.id, card, false, fk.ReasonPrey)
      end
    else
      room:notifySkillInvoked(player, "ofl__xiongnve", "defensive")
      data.damage = data.damage - 1
    end
  end,
}
local ofl__xiongnve_targetmod = fk.CreateTargetModSkill{
  name = "#ofl__xiongnve_targetmod",
  bypass_times = function(self, player, skill, scope, card, to)
    return card and player:getMark("@ofl__xiongnve_choice-turn") == "ofl__xiongnve_effect3"
  end,
}
Fk:loadTranslationTable{
  ["ofl__shilus"] = "嗜戮",
  [":ofl__shilus"] = "游戏开始时，你从剩余武将牌堆获得两张“戮”；其他角色死亡时，你可将其武将牌置为“戮”；当你杀死其他角色时，你从剩余武将牌堆"..
  "额外获得两张“戮”。回合开始时，你可以弃置至多X张牌（X为“戮”数），摸等量的牌。",
  ["ofl__xiongnve"] = "凶虐",
  [":ofl__xiongnve"] = "出牌阶段开始时，你可以移去一张“戮”并选择一项：1.本回合造成伤害+1；2.本回合对其他角色造成伤害时，你获得其一张牌；"..
  "3.本回合使用牌无次数限制。<br>出牌阶段结束时，你可以移去两张“戮”，你受到其他角色的伤害-1直到你下回合开始。",

  ["@&massacre"] = "戮",
  ["#ofl__shilus-cost"] = "嗜戮：你可以弃置至多%arg张牌，摸等量的牌",
  ["#ofl__shilus-invoke"] = "嗜戮：是否将 %dest 的武将牌置为“戮”？",
  ["#ofl__xiongnve-chooose"] = "凶虐：你可以弃置一张“戮”，获得一项效果",
  ["ofl__xiongnve_choice1"] = "增加伤害",
  ["ofl__xiongnve_choice2"] = "造成伤害时拿牌",
  ["ofl__xiongnve_choice3"] = "用牌无次数限制",
  ["#ofl__xiongnve-defence"] = "凶虐：你可以弃置两张“戮”，受到伤害-1直到你下回合开始",
  ["@ofl__xiongnve_choice-turn"] = "凶虐",
  ["ofl__xiongnve_effect1"] = "增加伤害",
  ["ofl__xiongnve_effect2"] = "造伤拿牌",
  ["ofl__xiongnve_effect3"] = "无限用牌",
  ["@@ofl__xiongnve"] = "凶虐",

  ["$ofl__shilus1"] = "以杀立威，谁敢反我？",
  ["$ofl__shilus2"] = "将这些乱臣贼子，尽皆诛之！",
  ["$ofl__xiongnve1"] = "当今天子乃我所立，他敢怎样？",
  ["$ofl__xiongnve2"] = "我兄弟三人同掌禁军，有何所惧？",
}
