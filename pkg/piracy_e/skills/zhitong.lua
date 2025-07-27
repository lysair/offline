local zhitong = fk.CreateSkill {
  name = "ofl__zhitong",
  tags = { Skill.Switch },
}

Fk:loadTranslationTable{
  ["ofl__zhitong"] = "治统",
  [":ofl__zhitong"] = "转换技，当你使用牌时，若目标：阳：包含自己，你摸两张牌并回复1点体力；阴：包含其他角色，"..
  "你获得其装备区所有牌并对其造成1点伤害。",
}

zhitong:addEffect(fk.CardUsing, {
  anim_type = "switch",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(zhitong.name) then
      if player:getSwitchSkillState(zhitong.name, false) == fk.SwitchYang then
        return table.contains(data.tos or {}, player)
      else
        return table.find(data.tos or {}, function (p)
          return p ~= player and not p.dead
        end)
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player:getSwitchSkillState(zhitong.name, true) == fk.SwitchYang then
      player:drawCards(2, zhitong.name)
      if not player.dead then
        room:recover{
          who = player,
          num = 1,
          recoverBy = player,
          skillName = zhitong.name,
        }
      end
    else
      for _, p in ipairs(room:getOtherPlayers(player)) do
        if not p.dead and table.contains(data.tos, p) then
          if #p:getCardIds("e") > 0 and not player.dead then
            room:moveCardTo(p:getCardIds("e"), Card.PlayerHand, player, fk.ReasonPrey, zhitong.name, nil, true, player)
          end
          if not p.dead then
            room:damage{
              from = player,
              to = p,
              damage = 1,
              skillName = zhitong.name,
            }
          end
        end
      end
    end
  end,
})

return zhitong
