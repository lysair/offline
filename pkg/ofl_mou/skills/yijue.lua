
local yijue = fk.CreateSkill{
  name = "ofl_mou__yijue",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_mou__yijue"] = "义绝",
  [":ofl_mou__yijue"] = "锁定技，准备阶段，你令所有其他角色依次选择是否交给你一张牌，以此法交给你牌的角色本回合首次受到你的【杀】"..
  "造成的伤害时，防止此伤害。",

  ["#ofl_mou__yijue-give"] = "义绝；你可以交给 %src 一张牌，防止其本回合【杀】对你造成的首次伤害",
  ["@@ofl_mou__yijue-turn"] = "义绝",

  ["$ofl_mou__yijue1"] = "大丈夫处事，只以忠义为先。",
  ["$ofl_mou__yijue2"] = "马行忠魂路，刀斩不义敌！",
}

yijue:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yijue.name) and player.phase == Player.Start and
      table.find(player.room.alive_players, function(p)
        return player ~= p and not p:isNude()
      end)
  end,
  on_cost = function (self, event, target, player, data)
    event:setCostData(self, {tos = player.room:getOtherPlayers(player)})
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if player.dead then return end
      if not p:isNude() and not p.dead then
        local cards = room:askToCards(p, {
          min_num = 1,
          max_num = 1,
          include_equip = true,
          skill_name = yijue.name,
          prompt = "#ofl_mou__yijue-give:" .. player.id,
          cancelable = true,
        })
        if #cards > 0 then
          room:setPlayerMark(p, "@@ofl_mou__yijue-turn", player.id)
          room:obtainCard(player, cards, false, fk.ReasonGive, p, yijue.name)
        end
      end
    end
  end,
})

yijue:addEffect(fk.DamageInflicted, {
  anim_type = "negative",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target:getMark("@@ofl_mou__yijue-turn") == player.id and
      data.from == player and data.card and data.card.trueName == "slash"
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(target, "@@ofl_mou__yijue-turn", 0)
    data:preventDamage()
  end,
})

return yijue
