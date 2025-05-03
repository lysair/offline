local huiji = fk.CreateSkill {
  name = "sxfy__huiji",
}

Fk:loadTranslationTable{
  ["sxfy__huiji"] = "挥戟",
  [":sxfy__huiji"] = "你使用【杀】可以额外指定至多两名角色为目标，若如此做，此【杀】的目标角色可以令其他目标角色选择是否代替其使用【闪】"..
  "来抵消此【杀】。",

  ["#sxfy__huiji-choose"] = "挥戟：你可以为%arg增加至多两个目标",
  ["#sxfy__huiji-invoke"] = "挥戟：是否令其他目标角色选择代替你使用【闪】？",
  ["#sxfy__huiji-ask"] = "挥戟：你可以替 %src 使用【闪】",
}

huiji:addEffect(fk.AfterCardTargetDeclared, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(huiji.name) and data.card.trueName == "slash" and
      #data:getExtraTargets() > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local tos = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 2,
      targets = data:getExtraTargets(),
      skill_name = huiji.name,
      prompt = "#sxfy__huiji-choose:::"..data.card:toLogString(),
      cancelable = true,
    })
    if #tos > 0 then
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    for _, p in ipairs(event:getCostData(self).tos) do
      data:addTarget(p)
    end
    data.extra_data = data.extra_data or {}
    data.extra_data.sxfy__huiji = true
  end,
})

huiji:addEffect(fk.AskForCardUse, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if target == player and
      Exppattern:Parse(data.pattern):matchExp("jink") and
      (data.extraData == nil or data.extraData.sxfy__huiji_ask == nil) then
      local e = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      if e then
        local use = e.data
        if use.card.trueName == "slash" and use.extra_data and use.extra_data.sxfy__huiji then
          local targets =  table.filter(use.tos, function (p)
            return p ~= player and not p.dead
          end)
          if #targets > 0 then
            event:setCostData(self, {tos = targets})
            return true
          end
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = "sxfy__huiji",
      prompt = "#sxfy__huiji-invoke",
    }) then
      local tos = event:getCostData(self).tos
      room:sortByAction(tos)
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(event:getCostData(self).tos) do
      if not p.dead then
        local respond = room:askToResponse(p, {
          skill_name = "jink",
          pattern = "jink",
          prompt = "#sxfy__huiji-ask:" .. player.id,
          cancelable = true,
          extra_data = {
            sxfy__huiji_ask = true,
          },
        })
        if respond then
          respond.skipDrop = true
          room:responseCard(respond)

          local new_card = Fk:cloneCard("jink")
          new_card.skillName = huiji.name
          new_card:addSubcards(room:getSubcardsByRule(respond.card, { Card.Processing }))
          data.result = {
            from = player,
            card = new_card,
            tos = {},
          }
          return true
        end
      end
    end
  end,
})

return huiji
