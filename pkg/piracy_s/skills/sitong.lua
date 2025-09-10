local sitong = fk.CreateSkill({
  name = "ofl__sitong",
})

Fk:loadTranslationTable{
  ["ofl__sitong"] = "泗恸",
  [":ofl__sitong"] = "每回合限一次，当一名角色使用的指定另一名魏势力角色为唯一目标的伤害牌结算结束后，你可以视为对其使用一张【杀】。",

  ["#ofl__sitong-invoke"] = "泗恸：你可以视为对 %dest 使用【杀】",
}

sitong:addEffect(fk.CardUseFinished, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(sitong.name) and
      data.card.is_damage_card and
      table.find(data.tos, function (p)
        return p.kingdom == "wei" and data:isOnlyTarget(p) and p ~= target
      end) and
      player:usedSkillTimes(sitong.name, Player.HistoryTurn) == 0 and
      not target.dead and player:canUseTo(Fk:cloneCard("slash"), target, { bypass_distances = true, bypass_times = true })
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = sitong.name,
      prompt = "#ofl__sitong-invoke::"..target.id,
    })
  end,
  on_use = function(self, event, target, player, data)
    player.room:useVirtualCard("slash", nil, player, target, sitong.name, true)
  end,
})

return sitong
