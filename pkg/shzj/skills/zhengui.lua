local zhengui = fk.CreateSkill {
  name = "zhengui",
}

Fk:loadTranslationTable{
  ["zhengui"] = "镇归",
  [":zhengui"] = "每个回合结束时，若本回合有蜀势力角色受到过伤害，你可以依次视为对伤害来源使用【决斗】。",

  ["#zhengui-invoke"] = "镇归：你可以视为对本回合对蜀势力角色造成过伤害的角色使用【决斗】！",

  ["$zhengui"] = "是时候，让敌人见识赵家真正的本领了！",
}

zhengui:addEffect(fk.TurnEnd, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(zhengui.name) and
      #player.room.logic:getActualDamageEvents(1, function (e)
        local damage = e.data
        return damage.to.kingdom == "shu" and damage.from and damage.from ~= player and not damage.from.dead
      end, Player.HistoryTurn) > 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = zhengui.name,
      prompt = "#zhengui-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    room.logic:getActualDamageEvents(1, function (e)
      local damage = e.data
      if damage.to.kingdom == "shu" and damage.from and damage.from ~= player and not damage.from.dead then
        table.insert(targets, damage.from)
      end
    end, Player.HistoryTurn)
    for _, p in ipairs(targets) do
      if player.dead then return end
      if not p.dead then
        room:useVirtualCard("duel", nil, player, p, zhengui.name)
      end
    end
  end,
})

return zhengui
