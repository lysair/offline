local xiongnve = fk.CreateSkill {
  name = "ofl__xiongnve",
}

Fk:loadTranslationTable{
  ["ofl__xiongnve"] = "凶虐",
  [":ofl__xiongnve"] = "出牌阶段开始时，你可以移去一张“戮”并选择一项：1.本回合造成伤害+1；2.本回合对其他角色造成伤害时，你获得其一张牌；"..
  "3.本回合使用牌无次数限制。<br>出牌阶段结束时，你可以移去两张“戮”，你受到其他角色的伤害-1直到你下回合开始。",

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

  ["$ofl__xiongnve1"] = "当今天子乃我所立，他敢怎样？",
  ["$ofl__xiongnve2"] = "我兄弟三人同掌禁军，有何所惧？",
}

xiongnve:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xiongnve.name) and player.phase == Player.Play and
      #player:getTableMark("@&massacre") > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local result = room:askToCustomDialog(player, {
      skill_name = xiongnve.name,
      qml_path = "packages/utility/qml/ChooseGeneralsAndChoiceBox.qml",
      extra_data = {
        player:getMark("@&massacre"),
        {"ofl__xiongnve_choice1", "ofl__xiongnve_choice2", "ofl__xiongnve_choice3"},
        "#ofl__xiongnve-chooose",
        {"Cancel"}
      }
    })
    if result ~= "" then
      local reply = result
      if reply.choice ~= "Cancel" then
        event:setCostData(self, {reply.cards, reply.choice})
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
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

xiongnve:addEffect(fk.EventPhaseEnd, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xiongnve.name) and player.phase == Player.Play and
      #player:getTableMark("@&massacre") > 1
  end,
  on_cost = function(self, event, target, player, data)
    local result = player.room:askToCustomDialog(player, {
      skill_name = xiongnve.name,
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
      if result.choice == "OK" then
        event:setCostData(self, {result.cards})
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
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

xiongnve:addEffect(fk.TurnStart, {
  can_refresh = function(self, event, target, player, data)
    return target == player
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@ofl__xiongnve", 0)
  end,
})

xiongnve:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if target == player and not player.dead then
      if not data.to.dead then
        if player:getMark("@ofl__xiongnve_choice-turn") == "ofl__xiongnve_effect1" then
          return true
        elseif player:getMark("@ofl__xiongnve_choice-turn") == "ofl__xiongnve_effect2" then
          return #data.to:getCardIds("e") > 0 or (not data.to:isKongcheng() and data.to ~= player)
        end
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    event:setCostData(self, {tos = {data.to}})
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player:getMark("@ofl__xiongnve_choice-turn") == "ofl__xiongnve_effect1" then
      data:changeDamage(1)
    elseif player:getMark("@ofl__xiongnve_choice-turn") == "ofl__xiongnve_effect2" then
      local flag = data.to == player and "e" or "he"
      local card = room:askToChooseCard(player, {
        target = data.to,
        flag = flag,
        skill_name = xiongnve.name,
      })
      room:obtainCard(player, card, false, fk.ReasonPrey, player, xiongnve.name)
    end
  end,
})

xiongnve:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@@ofl__xiongnve") > 0 and data.from and data.from ~= player
  end,
  on_use = function(self, event, target, player, data)
    data:changeDamage(-1)
  end,
})

xiongnve:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    return card and player:getMark("@ofl__xiongnve_choice-turn") == "ofl__xiongnve_effect3"
  end,
})

return xiongnve
