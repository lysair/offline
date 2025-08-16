local zhuhui = fk.CreateSkill {
  name = "zhuhui",
}

Fk:loadTranslationTable{
  ["zhuhui"] = "烛晦",
  [":zhuhui"] = "每轮限一次，一名男性角色的回合开始时，你可以令其选择一项：<br>"..
  "1.你获得〖清俭〗直到本轮结束，然后其交给你至少一张手牌；<br>"..
  "2.你获得〖急救〗直到本轮结束，然后其受到至少1点雷电伤害。",

  ["#zhuhui-invoke"] = "烛晦：你可以令 %dest 选择一项",
  ["zhuhui_qingjian"] = "%src本轮获得“清俭”，你交给其至少一张手牌",
  ["zhuhui_jijiu"] = "%src本轮获得“急救”，你受到至少1点雷电伤害",
  ["#zhuhui-give"] = "烛晦：请交给 %src 至少一张手牌",
  ["#zhuhui-damage"] = "烛晦：受到至少1点雷电伤害",
}

zhuhui:addEffect(fk.TurnStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(zhuhui.name) and
      target:isMale() and not target.dead and player:usedSkillTimes(zhuhui.name, Player.HistoryRound) == 0 and
      not (player:hasSkill("ex__qingjian", true) and player:hasSkill("jijiu", true))
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = zhuhui.name,
      prompt = "#zhuhui-invoke::"..target.id,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choices = {}
    if not player:hasSkill("ex__qingjian", true) then
      table.insert(choices, "zhuhui_qingjian:"..player.id)
    end
    if not player:hasSkill("jijiu", true) then
      table.insert(choices, "zhuhui_jijiu:"..player.id)
    end
    local choice = room:askToChoice(target, {
      choices = choices,
      skill_name = zhuhui.name,
    })
    if choice:startsWith("zhuhui_qingjian") then
      room:handleAddLoseSkills(player, "ex__qingjian")
      room.logic:getCurrentEvent():findParent(GameEvent.Round):addCleaner(function()
        room:handleAddLoseSkills(player, "-ex__qingjian")
      end)
      if not player.dead and not target.dead and not target:isKongcheng() and target ~= player then
        local cards = room:askToCards(target, {
          min_num = 1,
          max_num = 999,
          include_equip = false,
          skill_name = zhuhui.name,
          prompt = "#zhuhui-give:"..player.id,
          cancelable = false,
        })
        room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonGive, zhuhui.name, nil, false, target)
      end
    else
      room:handleAddLoseSkills(player, "jijiu")
      room.logic:getCurrentEvent():findParent(GameEvent.Round):addCleaner(function()
        room:handleAddLoseSkills(player, "-jijiu")
      end)
      if not target.dead and target.hp > 0 then
        choices = {}
        for i = 1, target.hp do
          table.insert(choices, tostring(i))
        end
        choice = room:askToChoice(target, {
          choices = choices,
          skill_name = zhuhui.name,
          prompt = "#zhuhui-damage",
        })
        room:damage{
          to = target,
          damage = tonumber(choice),
          skillName = zhuhui.name,
        }
      end
    end
  end,
})

return zhuhui
