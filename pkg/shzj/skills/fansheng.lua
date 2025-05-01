local fansheng = fk.CreateSkill {
  name = "fansheng",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["fansheng"] = "反生",
  [":fansheng"] = "锁定技，当你第一次进入濒死时，你将体力回复至1点，然后令所有其他角色依次选择弃置其所有手牌或弃置其装备区里的所有牌。",

  ["xihun-hand"] = "弃置所有手牌",
  ["xihun-equip"] = "弃置装备区所有牌",
}

fansheng:addEffect(fk.EnterDying, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(fansheng.name) and player:getMark(fansheng.name) == 0
  end,
  on_cost = function(self, event, target, player, data)
    event:setCostData(self, {tos = player.room:getOtherPlayers(player)})
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:recover{
      who = player,
      num = 1 - player.hp,
      recoverBy = player,
      skillName = fansheng.name,
    }
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if not p.dead then
        local choices = {}
        if table.find(p:getCardIds("h"), function (id)
          return not p:prohibitDiscard(id)
        end) then
          table.insert(choices, "xihun-hand")
        end
        if #p:getCardIds("e") > 0 then
          table.insert(choices, "xihun-equip")
        end
        if #choices then
          local choice = room:askToChoice(p, {
            choices = choices,
            skill_name = fansheng.name,
          })
          if choice == "xihun-hand" then
            p:throwAllCards("h", fansheng.name)
          elseif choice == "xihun-equip" then
            p:throwAllCards("e", fansheng.name)
          end
        end
      end
    end
  end,
})

return fansheng
