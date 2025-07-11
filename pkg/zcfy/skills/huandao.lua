local huandao = fk.CreateSkill {
  name = "sxfy__huandao",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["sxfy__huandao"] = "寰道",
  [":sxfy__huandao"] = "限定技，出牌阶段，你可以令一名其他角色复原武将牌，然后其可以声明并获得一项未被封印的同名武将的技能并选择失去一项其他技能。",

  ["#sxfy__huandao"] = "寰道：令一名角色复原武将牌并获得同名武将技能",
  ["#sxfy__huandao-choose"] = "寰道：你可以获得其中一个技能，然后选择另一项技能失去",
}

huandao:addEffect("active", {
  anim_type = "support",
  prompt = "#sxfy__huandao",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(huandao.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local target = effect.tos[1]
    target:reset()
    if target.dead then return end
    local generals = Fk:getSameGenerals(target.general)
    local name = Fk.generals[target.general].name
    if name:startsWith("god") then
      table.insertTableIfNeed(generals, Fk:getSameGenerals(string.sub(name, 4)))
    else
      table.insertTableIfNeed(generals, Fk:getSameGenerals("god" .. name))
      if Fk.generals["god" .. name] then
        table.insertIfNeed(generals, "god" .. name)
      end
    end

    if target.deputyGeneral and target.deputyGeneral ~= "" then
      table.insertTableIfNeed(generals, Fk:getSameGenerals(target.deputyGeneral))
      name = Fk.generals[target.deputyGeneral].name
      if name:startsWith("god") then
        table.insertTableIfNeed(generals, Fk:getSameGenerals(string.sub(name, 4)))
      else
        table.insertTableIfNeed(generals, Fk:getSameGenerals("god" .. name))
        if Fk.generals["god" .. name] then
          table.insertIfNeed(generals, "god" .. name)
        end
      end
    end
    generals = table.filter(generals, function(general)
      return not general:startsWith("sxfy")
    end)
    if #generals == 0 then return end

    local skills = {}
    for _, general in ipairs(generals) do
      table.insert(skills, Fk.generals[general]:getSkillNameList(target.role == "lord"))
    end

    local result = room:askToCustomDialog(target, {
      skill_name = huandao.name,
      qml_path = "packages/tenyear/qml/ChooseGeneralSkillsBox.qml",
      extra_data = { generals, skills, 1, 1, "#sxfy__huandao-choose", true }
    })
    if result == "" then return end
    local skill = json.decode(result)[1]
    room:handleAddLoseSkills(target, skill)
    local choices = target:getSkillNameList()
    table.removeOne(choices, skill)
    if #choices > 0 then
      local choice = room:askToChoice(target, {
        choices = choices,
        skill_name = huandao.name,
        prompt = "#huandao-lose",
      })
      room:handleAddLoseSkills(target, "-"..choice)
    end
  end,
})

return huandao
