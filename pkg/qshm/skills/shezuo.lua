local shezuo = fk.CreateSkill {
  name = "shezuo",
}

Fk:loadTranslationTable {
  ["shezuo"] = "设座",
  [":shezuo"] = "准备阶段，你可以选择一项，本回合下次拼点结算后拼点没赢的角色执行：1.依次弃置两张牌，不足则失去等量体力；"..
  "2.横置并受到1点火焰伤害；3.将所有手牌当任意一张普通锦囊牌使用。出牌阶段限一次，你可以摸一张牌并拼点。",

  ["#shezuo-choice"] = "设座：你可以选择一项，本回合下次拼点结算后，没赢的角色执行选项",
  ["shezuo1"] = "依次弃置两张牌，不足则失去等量体力",
  ["shezuo2"] = "横置并受到1点火焰伤害",
  ["shezuo3"] = "将所有手牌当任意一张普通锦囊牌使用",
  ["@shezuo-turn"] = "设座",
  ["#shezuo"] = "设座：你可以摸一张牌，然后与一名角色拼点",
  ["#shezuo-choose"] = "设座：与一名角色拼点",
  ["#shezuo-discard"] = "设座：依次弃置两张牌，若不足则失去体力！",
  ["#shezuo-use"] = "设座：请将所有手牌当任意一张普通锦囊牌使用",
}

shezuo:addEffect("active", {
  anim_type = "drawcard",
  prompt = "#shezuo",
  card_num = 0,
  target_num = 0,
  can_use = function (self, player)
    return player:usedEffectTimes(self.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    player:drawCards(1, shezuo.name)
    if player.dead then return end
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return player:canPindian(p)
    end)
    if #targets == 0 then return end
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = shezuo.name,
      prompt = "#shezuo-choose",
      cancelable = false,
    })[1]
    player:pindian({to}, shezuo.name)
  end,
})

shezuo:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(shezuo.name) and player.phase == Player.Start
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local choice = room:askToChoice(player, {
      choices = {
        "shezuo1",
        "shezuo2",
        "shezuo3",
        "Cancel",
      },
      skill_name = shezuo.name,
      prompt = "#shezuo-choice",
    })
    if choice ~= "Cancel" then
      event:setCostData(self, {choice = choice})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local choice = event:getCostData(self).choice
    choice = tonumber(choice[7])
    room:addTableMarkIfNeed(player, "@shezuo-turn", choice)
  end,
})

shezuo:addEffect(fk.PindianFinished, {
  anim_type = "offensive",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if player:getMark("@shezuo-turn") ~= 0 then
      local room = player.room
      local choices = player:getTableMark("@shezuo-turn")
      room:setPlayerMark(player, "@shezuo-turn", 0)
      local targets = {}
      for _, p in ipairs(data.tos) do
        if data.results[p].winner ~= data.from then
          table.insertIfNeed(targets, data.from)
        end
        if data.results[p].winner ~= p then
          table.insertIfNeed(targets, p)
        end
      end
      targets = table.filter(targets, function (p)
        return not p.dead
      end)
      if #targets > 0 then
        room:sortByAction(targets)
        event:setCostData(self, {tos = targets, choice = choices})
        return true
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local tos = event:getCostData(self).tos
    local choices = event:getCostData(self).choice
    for _, choice in ipairs(choices) do
      for _, to in ipairs(tos) do
        if not to.dead then
          if choice == 1 then
            local n = 0
            for _ = 1, 2 do
              if not to.dead and
                #room:askToDiscard(to, {
                  min_num = 1,
                  max_num = 1,
                  include_equip = true,
                  skill_name = shezuo.name,
                  cancelable = false,
                  prompt = "#shezuo-discard",
                }) == 0 then
                n = n + 1
              end
            end
            if not to.dead and n > 0 then
              room:loseHp(to, n, shezuo.name)
            end
          elseif choice == 2 then
            if not to.chained then
              to:setChainState(true)
            end
            if not to.dead then
              room:damage{
                from = nil,
                to = to,
                damage = 1,
                damageType = fk.FireDamage,
                skillName = shezuo.name,
              }
            end
          elseif choice == 3 then
            if not to:isKongcheng() then
              local names = to:getViewAsCardNames(shezuo.name, Fk:getAllCardNames("t"), to:getCardIds("h"))
              local success, dat = room:askToUseActiveSkill(to, {
                skill_name = "shezuo_viewas",
                prompt = "#shezuo-use",
                cancelable = #names == 0,
              })
              if not (success and dat) then
                dat = {}
                dat.interaction = table.random(names)
                dat.targets = {}
              end
              local card = Fk:cloneCard(dat.interaction)
              card.skillName = shezuo.name
              card:addSubcards(to:getCardIds("h"))
              if #dat.targets == 0 then
                dat.targets = card:getAvailableTargets(to, {bypass_times = true})
              end
              room:useCard{
                from = to,
                tos = dat.targets,
                card = card,
                extraUse = true,
              }
            end
          end
        end
      end
    end
  end,
})

return shezuo
