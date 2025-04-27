
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
