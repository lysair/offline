local fengbai = fk.CreateSkill {
  name = "sxfy__fengbai",
  tags = { Skill.Lord },
}

Fk:loadTranslationTable{
  ["sxfy__fengbai"] = "封拜",
  [":sxfy__fengbai"] = "主公技，当你获得一名群势力角色装备区里的一张牌后，你可以令其摸一张牌。",

  ["#sxfy__fengbai-invoke"] = "封拜：是否令 %dest 摸一张牌？",
}

fengbai:addEffect(fk.AfterCardsMove, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(fengbai.name) then
      for _, move in ipairs(data) do
        if move.to == player and move.toArea == Player.Hand and move.from and
          move.from.kingdom == "qun" then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerEquip then
              return true
            end
          end
        end
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    local dat = {}
    for _, move in ipairs(data) do
      if move.to == player and move.toArea == Player.Hand and move.from and
        move.from.kingdom == "qun" then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerEquip then
            dat[move.from] = (dat[move.from] or 0) + 1
          end
        end
      end
    end
    for _, p in ipairs(room:getAlivePlayers()) do
      if dat[p] then
        local n = dat[p]
        for _ = 1, n do
          if not player:hasSkill(fengbai.name) or p.dead or event:getSkillData(self, "cancel_cost") then break end
          event:setSkillData(self, "cancel_cost", false)
          event:setCostData(self, {tos = {p}})
          self:doCost(event, target, player, data)
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askToSkillInvoke(player, {
      skill_name = fengbai.name,
      prompt = "#sxfy__fengbai-invoke::"..event:getCostData(self).tos[1].id,
    }) then
      return true
    end
    event:setSkillData(self, "cancel_cost", true)
  end,
  on_use = function(self, event, target, player, data)
    event:getCostData(self).tos[1]:drawCards(1, fengbai.name)
  end,
})

return fengbai
