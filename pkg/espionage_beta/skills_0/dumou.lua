local dumou = fk.CreateSkill {
  name = "dumou",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["dumou"] = "毒谋",
  [":dumou"] = "锁定技，你的回合内，其他角色的黑色手牌均视为【毒】，你的【毒】均视为【过河拆桥】。",
}

dumou:addEffect("filter", {
  card_filter = function(self, player, to_select)
    if player:hasSkill(skill.name) and player.phase ~= Player.NotActive and table.contains(player:getCardIds("h"), to_select.id) then
      return to_select.trueName == "poison"
    end
    if table.find(Fk:currentRoom().alive_players, function(p)
      return p.phase ~= Player.NotActive and p:hasSkill(skill.name) and p ~= player and table.contains(p.player_skills, skill)
    end) and table.contains(player:getCardIds("h"), to_select.id) then
      return to_select.color == Card.Black
    end
  end,
  view_as = function(self, player, to_select)
    local card
    if player.phase == Player.NotActive then
      card = Fk:cloneCard("es__poison", to_select.suit, to_select.number)
    else
      card = Fk:cloneCard("dismantlement", to_select.suit, to_select.number)
    end
    card.skillName = dumou.name
    return card
  end,
})

return dumou
