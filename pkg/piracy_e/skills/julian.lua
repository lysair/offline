local julian = fk.CreateSkill{
  name = "ofl__julian",
  tags = { Skill.Lord },
}

Fk:loadTranslationTable{
  ["ofl__julian"] = "聚敛",
  [":ofl__julian"] = "主公技，结束阶段，其他群势力角色依次可以选择摸两张牌，若如此做，你获得其一张牌。",

  ["#ofl__julian-draw"] = "聚敛：你可以摸两张牌，然后 %src 获得你一张牌",
  ["#ofl__julian-prey"] = "聚敛：获得 %dest 一张牌",

  ["$ofl__julian1"] = "官爵乃身外之物，鬻之！",
  ["$ofl__julian2"] = "以爵易物，岂不美哉？",
}

julian:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(julian.name) and player.phase == Player.Finish and
      table.find(player.room:getOtherPlayers(player, false), function (p)
        return p.kingdom == "qun"
      end)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local tos = table.filter(room:getOtherPlayers(player), function (p)
      return p.kingdom == "qun"
    end)
    event:setCostData(self, {tos = tos})
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = event:getCostData(self).tos
    for _, p in ipairs(targets) do
      if not p.dead and p.kingdom == "qun" and
      room:askToSkillInvoke(p, {
        skill_name = julian.name,
        prompt = "#ofl__julian-draw:"..player.id,
      }) then
        p:drawCards(1, julian.name)
        if player.dead then return end
        if not p.dead and not p:isNude() then
          room:doIndicate(player, {p})
          local card = room:askToChooseCard(player, {
            target = p,
            flag = "he",
            skill_name = julian.name,
            prompt = "#ofl__julian-prey::"..p.id,
          })
          room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, julian.name, nil, false, player)
        end
      end
    end
  end,
})

return julian
