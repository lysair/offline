local fengxie = fk.CreateSkill {
  name = "fengxie",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["fengxie"] = "奉挟",
  [":fengxie"] = "限定技，出牌阶段，你可以选择一名其他角色，你依次选择除其以外每名角色装备区内的一张牌，移动至目标角色的装备区内，"..
  "若无法移动，改为你获得之。然后明忠失去忠臣技，你获得之。",

  ["#fengxie"] = "奉挟：指定一名角色，将每名角色的一张装备移动至目标角色，若无法移动则你获得",
}

fengxie:addEffect("active", {
  anim_type = "control",
  prompt = "#fengxie",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(fengxie.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    for _, p in ipairs(room:getOtherPlayers(target)) do
      if player.dead then return end
      if not p.dead and #p:getCardIds("e") > 0 then
        room:doIndicate(player, {p})
        local card = room:askToChooseCard(player, {
          target = p,
          flag = "e",
          skill_name = fengxie.name,
        })
        if target.dead or not target:canMoveCardIntoEquip(card, false) then
          room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, fengxie.name, nil, true, player)
        else
          room:moveCardIntoEquip(target, card, fengxie.name, false, player)
        end
      end
    end
    if not player.dead and room:getBanner("ShownLoyalist") then
      local to = room:getPlayerById(room:getBanner("ShownLoyalist"))
      local all_skills = {"vd_dongcha", "vd_sheshen"}
      local skills = {}
      for _, skill in ipairs(all_skills) do
        if Fk.skills[skill] and to:hasSkill(skill, true) then
          table.insert(skills, skill)
        end
      end
      if #skills > 0 then
        room:doIndicate(player, {to})
        room:handleAddLoseSkills(to, "-"..table.concat(skills, "|-"))
        room:handleAddLoseSkills(player, skills)
      end
    end
  end,
})

return fengxie