local ofl__xiongnve = fk.CreateSkill { name = "ofl__xiongnve" }

Fk:loadTranslationTable {
  ['ofl__xiongnve'] = '凶虐',
  ['@&massacre'] = '戮',
  ['ofl__xiongnve_choice1'] = '增加伤害',
  ['ofl__xiongnve_choice2'] = '造成伤害时拿牌',
  ['ofl__xiongnve_choice3'] = '用牌无次数限制',
  ['#ofl__xiongnve-chooose'] = '凶虐：你可以弃置一张“戮”并获得一项效果',
  ['#ofl__xiongnve-defence'] = '凶虐：你可以弃置两张“戮”，受到伤害-1直到你下回合开始',
  ['@ofl__xiongnve_choice-turn'] = '凶虐',
  ['@@ofl__xiongnve'] = '凶虐',
  ['ofl__xiongnve_effect1'] = '增加伤害',
  ['ofl__xiongnve_effect2'] = '造伤拿牌',
  ['ofl__xiongnve_effect3'] = '无限用牌',
  [':ofl__xiongnve'] = '出牌阶段开始时，你可以移去一张“戮”并选择一项：1.本回合造成伤害+1；2.本回合对其他角色造成伤害时，你获得其一张牌；3.本回合使用牌无次数限制。<br>出牌阶段结束时，你可以移去两张“戮”，你受到其他角色的伤害-1直到你下回合开始。',
  ['$ofl__xiongnve1'] = '当今天子乃我所立，他敢怎样？',
  ['$ofl__xiongnve2'] = '我兄弟三人同掌禁军，有何所惧？',
}

ofl__xiongnve:addEffect(fk.EventPhaseStart, {
  mute = true,
  can_trigger = function(self, event, target, player)
    if target == player and player:hasSkill(ofl__xiongnve) and player.phase == Player.Play then
      local n = #player:getTableMark("@&massacre")
      return n > 0
    end
  end,
  on_cost = function(self, event, target, player)
    local result = player.room:askToCustomDialog(player, {
      skill_name = ofl__xiongnve.name,
      qml_path = "packages/utility/qml/ChooseGeneralsAndChoiceBox.qml",
      extra_data = {
        player:getMark("@&massacre"),
        {"ofl__xiongnve_choice1", "ofl__xiongnve_choice2", "ofl__xiongnve_choice3"},
        "#ofl__xiongnve-chooose",
        {"Cancel"}
      }
    })
    if result ~= "" then
      local reply = json.decode(result)
      if reply.choice ~= "Cancel" then
        event:setCostData(self, {reply.cards, reply.choice})
        return true
      end
    end
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    player:broadcastSkillInvoke("xiongnve")
    room:notifySkillInvoked(player, ofl__xiongnve.name, "offensive")

    local generals = player:getTableMark("@&massacre")
    for _, name in ipairs(event:getCostData(self)[1]) do
      table.removeOne(generals, name)
    end

    if #generals == 0 then
      room:setPlayerMark(player, "@&massacre", 0)
    else
      room:setPlayerMark(player, "@&massacre", generals)
    end

    room:returnToGeneralPile(event:getCostData(self)[1])
    room:setPlayerMark(player, "@ofl__xiongnve_choice-turn", "ofl__xiongnve_effect" .. string.sub(event:getCostData(self)[2], 21, 21))
  end,
})

ofl__xiongnve:addEffect(fk.EventPhaseEnd, {
  mute = true,
  can_trigger = function(self, event, target, player)
    if target == player and player:hasSkill(ofl__xiongnve) and player.phase == Player.Play then
      local n = #player:getTableMark("@&massacre")
      return n > 1
    end
  end,
  on_cost = function(self, event, target, player)
    local result = player.room:askToCustomDialog(player, {
      skill_name = ofl__xiongnve.name,
      qml_path = "packages/utility/qml/ChooseGeneralsAndChoiceBox.qml",
      extra_data = {
        player:getMark("@&massacre"),
        {"OK"},
        "#ofl__xiongnve-defence",
        {"Cancel"},
        2,
        2
      }
    })
    if result ~= "" then
      local reply = json.decode(result)
      if reply.choice == "OK" then
        event:setCostData(self, {reply.cards})
        return true
      end
    end
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    player:broadcastSkillInvoke("xiongnve")
    room:notifySkillInvoked(player, ofl__xiongnve.name, "defensive")

    local generals = player:getTableMark("@&massacre")
    for _, name in ipairs(event:getCostData(self)[1]) do
      table.removeOne(generals, name)
    end

    if #generals == 0 then
      room:setPlayerMark(player, "@&massacre", 0)
    else
      room:setPlayerMark(player, "@&massacre", generals)
    end

    room:returnToGeneralPile(event:getCostData(self)[1])
    room:setPlayerMark(player, "@@ofl__xiongnve", 1)
  end,
})

ofl__xiongnve:addEffect(fk.TurnStart, {
  mute = true,
  can_refresh = function(self, event, target, player)
    return target == player and player:getMark("@@ofl__xiongnve") ~= 0
  end,
  on_refresh = function(self, event, target, player)
    player.room:setPlayerMark(player, "@@ofl__xiongnve", 0)
  end,
})

ofl__xiongnve:addEffect(fk.DamageCaused, {
  mute = true,
  can_trigger = function(self, event, target, player)
    if target == player and not player.dead then
      if not data.to.dead then
        local effect_name = player:getMark("@ofl__xiongnve_choice-turn")
        if effect_name == "ofl__xiongnve_effect1" then
          return true
        elseif effect_name == "ofl__xiongnve_effect2" then
          return #data.to:getCardIds("e") > 0 or (not data.to:isKongcheng() and data.to ~= player)
        end
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("xiongnve")
    room:doIndicate(player.id, {data.to.id})
    local effect_name = player:getMark("@ofl__xiongnve_choice-turn")
    if effect_name == "ofl__xiongnve_effect1" then
      room:notifySkillInvoked(player, "ofl__xiongnve", "offensive")
      data.damage = data.damage + 1
    elseif effect_name == "ofl__xiongnve_effect2" then
      room:notifySkillInvoked(player, "ofl__xiongnve", "control")
      local flag = data.to == player and "e" or "he"
      local card = room:askToChooseCard(player, {
        target = data.to,
        flag = flag,
        skill_name = ofl__xiongnve.name
      })
      room:obtainCard(player.id, card, false, fk.ReasonPrey)
    end
  end,
})

ofl__xiongnve:addEffect(fk.DamageInflicted, {
  mute = true,
  can_trigger = function(self, event, target, player)
    return player:getMark("@@ofl__xiongnve") > 0 and data.from and data.from ~= player
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("xiongnve")
    room:notifySkillInvoked(player, "ofl__xiongnve", "defensive")
    data.damage = data.damage - 1
  end,
})

ofl__xiongnve:addEffect('targetmod', {
  bypass_times = function(self, player, skill, scope, card, to)
    return card and player:getMark("@ofl__xiongnve_choice-turn") == "ofl__xiongnve_effect3"
  end,
})

return ofl__xiongnve
