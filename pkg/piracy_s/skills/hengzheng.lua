local hengzheng = fk.CreateSkill {
  name = "ofl__hengzheng",
}

Fk:loadTranslationTable{
  ["ofl__hengzheng"] = "横征",
  [":ofl__hengzheng"] = "回合开始时，若你没有手牌或体力值为1，你可以获得所有角色区域内各一张牌。",
}

hengzheng:addEffect(fk.TurnStart, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(hengzheng.name) and
      (player:isKongcheng() or player.hp == 1) and
      table.find(player.room.alive_players, function (p)
        if p == player then
          return #player:getCardIds("ej") > 0
        else
          return not p:isAllNude()
        end
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = hengzheng.name,
    }) then
      event:setCostData(self, {tos = room:getAlivePlayers()})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getAlivePlayers()) do
      if not p.dead then
        local id
        if p == player then
          if #player:getCardIds("ej") > 0 then
            id = room:askToChooseCard(player, {
              target = p,
              flag = "ej",
              skill_name = hengzheng.name,
            })
          end
        else
          if not p:isAllNude() then
          id = room:askToChooseCard(player, {
            target = p,
            flag = "hej",
            skill_name = hengzheng.name,
          })
          end
        end
        if id then
          room:obtainCard(player, id, false, fk.ReasonPrey, player, hengzheng.name)
          if player.dead then return end
        end
      end
    end
  end,
})

return hengzheng
